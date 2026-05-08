Shader "Custom/Rock_Triplanar"
{
    Properties
    {
        [Header(Textures)]
        _Albedo ("Albedo", 2D) = "white" {}
        _NormalMap ("Normal", 2D) = "bump" {}
        _MAOHS ("MAOHS", 2D) = "white" {}

        [Header(Triplanar Settings)]
        _NormalIntensity ("Normal Intensity", Range(0, 2)) = 1
        _TileSize ("TileSize", Float) = 1
        _Blend ("Blend", Range(1, 10)) = 4

        [Header(Coordinate Space)]
        [Toggle(_TRIPLANAR_LOCAL_SPACE)] _UseLocalSpace ("UseLocalSpace", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        LOD 300

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        // Keyword requerido por el enunciado.
        // OFF = coordenadas globales/world
        // ON  = coordenadas locales/object
        #pragma multi_compile _ _TRIPLANAR_LOCAL_SPACE

        sampler2D _Albedo;
        sampler2D _NormalMap;
        sampler2D _MAOHS;

        float _NormalIntensity;
        float _TileSize;
        float _Blend;

        struct Input
        {
            float3 worldPos;

            float3 localPos;
            float3 localNormal;
            float3 customWorldNormal;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.localPos = v.vertex.xyz;
            o.localNormal = normalize(v.normal.xyz);
            o.customWorldNormal = normalize(UnityObjectToWorldNormal(v.normal));
        }

        float3 GetTriplanarWeights(float3 normal)
        {
            float3 weights = abs(normal);

            weights = pow(weights, _Blend);

            float weightSum = weights.x + weights.y + weights.z;
            weights /= max(weightSum, 0.0001);

            return weights;
        }

        float3 GetScaledPosition(float3 position)
        {
            return position / max(_TileSize, 0.0001);
        }

        fixed4 SampleTriplanarTexture(sampler2D textureSampler, float3 position, float3 weights)
        {
            float2 uvX = position.zy;
            float2 uvY = position.xz;
            float2 uvZ = position.xy;

            fixed4 sampleX = tex2D(textureSampler, uvX);
            fixed4 sampleY = tex2D(textureSampler, uvY);
            fixed4 sampleZ = tex2D(textureSampler, uvZ);

            return sampleX * weights.x +
                   sampleY * weights.y +
                   sampleZ * weights.z;
        }

        fixed3 SampleTriplanarNormal(float3 position, float3 weights)
        {
            float2 uvX = position.zy;
            float2 uvY = position.xz;
            float2 uvZ = position.xy;

            fixed3 normalX = UnpackNormal(tex2D(_NormalMap, uvX));
            fixed3 normalY = UnpackNormal(tex2D(_NormalMap, uvY));
            fixed3 normalZ = UnpackNormal(tex2D(_NormalMap, uvZ));

            normalX.xy *= _NormalIntensity;
            normalY.xy *= _NormalIntensity;
            normalZ.xy *= _NormalIntensity;

            fixed3 blendedNormal =
                normalX * weights.x +
                normalY * weights.y +
                normalZ * weights.z;

            return normalize(blendedNormal);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 triplanarPosition;
            float3 triplanarNormal;

            #if defined(_TRIPLANAR_LOCAL_SPACE)
                triplanarPosition = IN.localPos;
                triplanarNormal = normalize(IN.localNormal);
            #else
                triplanarPosition = IN.worldPos;
                triplanarNormal = normalize(IN.customWorldNormal);
            #endif

            triplanarPosition = GetScaledPosition(triplanarPosition);

            float3 weights = GetTriplanarWeights(triplanarNormal);

            fixed4 albedo = SampleTriplanarTexture(_Albedo, triplanarPosition, weights);
            fixed4 maohs = SampleTriplanarTexture(_MAOHS, triplanarPosition, weights);
            fixed3 normal = SampleTriplanarNormal(triplanarPosition, weights);

            o.Albedo = albedo.rgb;
            o.Normal = normal;

            // Interpretación típica de un packed map:
            // R = Metallic
            // G = Ambient Occlusion
            // A = Smoothness
            o.Metallic = maohs.r;
            o.Occlusion = maohs.g;
            o.Smoothness = maohs.a;

            o.Alpha = 1;
        }

        ENDCG
    }

    FallBack "Standard"
}