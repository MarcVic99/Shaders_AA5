Shader "Custom/VertexPaint_Final"
{
    Properties
    {

        _UVScale ("UV Scale", Float) = 1


        [Header(Material A)]

        _AAlbedo ("A - Albedo", 2D) = "white" {}
        _ANormal ("A - Normal", 2D) = "bump" {}
        _AMask ("A - MAOHS", 2D) = "white" {}


        [Header(Material B)]

        _BAlbedo ("B - Albedo", 2D) = "white" {}
        _BNormal ("B - Normal", 2D) = "bump" {}
        _BMask ("B - MAOHS", 2D) = "white" {}


        [Header(Snow)]

        _SnowAlbedo ("Snow - Albedo", 2D) = "white" {}
        _SnowNormal ("Snow - Normal", 2D) = "bump" {}
        _SnowMask ("Snow - MAOHS", 2D) = "white" {}


        [Header(Noise)]

        _NoiseTexA ("Noise A", 2D) = "gray" {}
        _NoiseTexB ("Noise B", 2D) = "gray" {}

        _NoiseScaleA ("Noise Scale A", Float) = 1
        _NoiseScaleB ("Noise Scale B", Float) = 4


        [Header(Blend Settings)]

        _BlendDistance ("Blend Distance", Range(0.001,1)) = 0.2
        _SnowBlendDistance ("Snow Blend Distance", Range(0.001,1)) = 0.2


        [Header(Displacement)]

        _DisplacementStrength ("Displacement Strength", Float) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        LOD 300

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows vertex:vert

        #pragma target 3.0

        #include "UnityCG.cginc"


        sampler2D _AAlbedo;
        sampler2D _ANormal;
        sampler2D _AMask;

        sampler2D _BAlbedo;
        sampler2D _BNormal;
        sampler2D _BMask;

        sampler2D _SnowAlbedo;
        sampler2D _SnowNormal;
        sampler2D _SnowMask;

        sampler2D _NoiseTexA;
        sampler2D _NoiseTexB;


        float _UVScale;

        float _NoiseScaleA;
        float _NoiseScaleB;

        float _BlendDistance;
        float _SnowBlendDistance;

        float _DisplacementStrength;


        struct Input
        {
            float2 uv_AAlbedo;
            float4 color : COLOR;
            float3 worldPos;
        };


        void vert(inout appdata_full v)
        {

            float displacementMask = v.color.b;

            // Move vertices along normal

            v.vertex.xyz +=
                v.normal *
                displacementMask *
                _DisplacementStrength;
        }


        void surf(Input IN, inout SurfaceOutputStandard o)
        {

            float2 uv = IN.uv_AAlbedo * _UVScale;


            float2 noiseUVA = IN.worldPos.xz * _NoiseScaleA;
            float2 noiseUVB = IN.worldPos.xz * _NoiseScaleB;

            float noiseA =
                tex2D(_NoiseTexA, noiseUVA).r;

            float noiseB =
                tex2D(_NoiseTexB, noiseUVB).r;

            // Combined noise

            float combinedNoise =
                (noiseA * 0.7) +
                (noiseB * 0.3);


            float vertexRed = IN.color.r;
            float vertexGreen = IN.color.g;


            float blendAB =
                vertexRed +
                (combinedNoise - 0.5);

            blendAB = smoothstep(
                0.5 - _BlendDistance,
                0.5 + _BlendDistance,
                blendAB
            );


            float snowBlend =
                vertexGreen +
                (combinedNoise - 0.5);

            snowBlend = smoothstep(
                0.5 - _SnowBlendDistance,
                0.5 + _SnowBlendDistance,
                snowBlend
            );


            float4 albedoA =
                tex2D(_AAlbedo, uv);

            float3 normalA =
                UnpackNormal(
                    tex2D(_ANormal, uv)
                );

            float4 maskA =
                tex2D(_AMask, uv);


            float4 albedoB =
                tex2D(_BAlbedo, uv);

            float3 normalB =
                UnpackNormal(
                    tex2D(_BNormal, uv)
                );

            float4 maskB =
                tex2D(_BMask, uv);


            float4 baseAlbedo =
                lerp(albedoA, albedoB, blendAB);

            float3 baseNormal =
                normalize(
                    lerp(normalA, normalB, blendAB)
                );

            float4 baseMask =
                lerp(maskA, maskB, blendAB);


            float4 snowAlbedo =
                tex2D(_SnowAlbedo, uv);

            float3 snowNormal =
                UnpackNormal(
                    tex2D(_SnowNormal, uv)
                );

            float4 snowMask =
                tex2D(_SnowMask, uv);


            float4 finalAlbedo =
                lerp(baseAlbedo, snowAlbedo, snowBlend);

            float3 finalNormal =
                normalize(
                    lerp(baseNormal, snowNormal, snowBlend)
                );

            float4 finalMask =
                lerp(baseMask, snowMask, snowBlend);


            float metallic = finalMask.r;
            float ao = finalMask.g;
            float height = finalMask.b;
            float smoothness = finalMask.a;


            o.Albedo = finalAlbedo.rgb;

            o.Normal = finalNormal;

            o.Metallic = metallic;

            o.Occlusion = ao;

            o.Smoothness = smoothness;
        }

        ENDCG
    }

    FallBack "Diffuse"
}