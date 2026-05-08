Shader "Custom/Rock_Triplanar_Simple"
{
    Properties
    {
        _MainTex ("Rock Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap ("Height Map", 2D) = "black" {}
        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _HeightStrength ("Height Strength", Range(0, 0.1)) = 0.02
        _Color ("Tint", Color) = (1,1,1,1)
        _Scale ("Texture Scale", Float) = 1
        _BlendSharpness ("Blend Sharpness", Range(1, 8)) = 4
        [Toggle] _UseLocalSpace ("Use Local Space", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _HeightMap;
        fixed4 _Color;
        float _Scale;
        float _BlendSharpness;
        float _UseLocalSpace;
        float _NormalStrength;
        float _HeightStrength;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
            float3 viewDir;
            float3 localPos;
            float3 localNormal;
            INTERNAL_DATA
        };

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.localPos = v.vertex.xyz;
            o.localNormal = v.normal;
        }

        fixed4 SampleTriplanarTexture(sampler2D tex, float3 pos, float3 blend)
        {
            fixed4 xTex = tex2D(tex, pos.zy);
            fixed4 yTex = tex2D(tex, pos.xz);
            fixed4 zTex = tex2D(tex, pos.xy);

            return xTex * blend.x + yTex * blend.y + zTex * blend.z;
        }

        float3 SampleTriplanarNormal(float3 pos, float3 blend)
        {
            float3 xNormal = UnpackNormal(tex2D(_NormalMap, pos.zy));
            float3 yNormal = UnpackNormal(tex2D(_NormalMap, pos.xz));
            float3 zNormal = UnpackNormal(tex2D(_NormalMap, pos.xy));

            xNormal.xy *= _NormalStrength;
            yNormal.xy *= _NormalStrength;
            zNormal.xy *= _NormalStrength;

            float3 finalNormal =
                xNormal * blend.x +
                yNormal * blend.y +
                zNormal * blend.z;

            return normalize(finalNormal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float useLocal = step(0.5, _UseLocalSpace);

            float3 pos = lerp(IN.worldPos, IN.localPos, useLocal);
            float3 normal = normalize(lerp(IN.worldNormal, IN.localNormal, useLocal));

            float3 blend = abs(normal);
            blend = pow(blend, _BlendSharpness);
            blend /= max(blend.x + blend.y + blend.z, 0.0001);

            pos *= _Scale;

            float height = SampleTriplanarTexture(_HeightMap, pos, blend).r;
            float3 viewDir = normalize(IN.viewDir);
            pos += viewDir * ((height - 0.5) * _HeightStrength);

            fixed4 finalColor = SampleTriplanarTexture(_MainTex, pos, blend);
            finalColor *= _Color;

            o.Albedo = finalColor.rgb;
            //o.Normal = SampleTriplanarNormal(pos, blend); //DOESN'T WORK WITH NORMAL, DON'T KNOW WHY ITS ALL BLACK
            o.Alpha = finalColor.a;
            o.Metallic = 0.0;
        }
        ENDCG
    }

    FallBack "Diffuse"
}