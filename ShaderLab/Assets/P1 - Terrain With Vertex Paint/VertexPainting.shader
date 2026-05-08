// Shader "Custom/VertexPaint"
// {
//     Properties
//     {
//         _UVScale ("UV Scale", Float) = 0.2

//         [Header(Material A)]
//         _AAlbedo ("A - Albedo", 2D) = "white" {}
//         _ANormal ("A - Normal", 2D) = "bump" {}
//         _AMAOHS ("A - MAOHS", 2D) = "white" {}

//         [Header(Material B)]
//         _BAlbedo ("B - Albedo", 2D) = "white" {}
//         _BNormal ("B - Normal", 2D) = "bump" {}
//         _BMAOHS ("B - MAOHS", 2D) = "white" {}

//         [Header(Blend)]
//         _NoiseScale ("Noise Scale", Float) = 1
//         _BlendDistance ("Blend Distance", Range(0,1)) = 0.5

//         [Header(Surface)]
//         _SnowMetallic ("Snow Metallic", Range(0,1)) = 0
//         _SnowSmoothness ("Snow Smoothness", Range(0,1)) = 0.1
//         _SnowAO ("Snow AO", Range(0,1)) = 1

//         [Header(Displacement)]
//         _VerticalDisplacement ("Vertical Displacement", Float) = 0.2
//     }

//     SubShader
//     {
//         Tags { "RenderType"="Opaque" }

//         CGPROGRAM

//         #pragma surface surf Standard fullforwardshadows vertex:vert

//         #include "UnityCG.cginc"

//         sampler2D _AAlbedo;
//         sampler2D _ANormal;
//         sampler2D _AMAOHS;

//         sampler2D _BAlbedo;
//         sampler2D _BNormal;
//         sampler2D _BMAOHS;

//         float _UVScale;
//         float _NoiseScale;
//         float _BlendDistance;

//         float _SnowMetallic;
//         float _SnowSmoothness;
//         float _SnowAO;

//         float _VerticalDisplacement;

//         struct Input
//         {
//             float2 uv_AAlbedo;
//             float4 color : COLOR;
//             float3 worldPos;
//         };

//         // -----------------------------
//         // Simple procedural noise
//         // -----------------------------

//         float Noise(float3 p)
//         {
//             return frac(sin(dot(p, float3(12.9898,78.233,45.543))) * 43758.5453);
//         }

//         // -----------------------------
//         // Vertex displacement
//         // -----------------------------

//         void vert(inout appdata_full v)
//         {
//             float mask = v.color.r;

//             v.vertex.y += mask * _VerticalDisplacement;
//         }

//         // -----------------------------
//         // Surface
//         // -----------------------------

//         void surf(Input IN, inout SurfaceOutputStandard o)
//         {
//             float2 uv = IN.uv_AAlbedo * _UVScale;

//             // Noise
//             float noise = Noise(IN.worldPos * _NoiseScale);

//             // Vertex mask
//             float mask = IN.color.r;

//             mask += (noise - 0.5) * _BlendDistance;

//             mask = saturate(mask);

//             // Albedo
//             float4 albedoA = tex2D(_AAlbedo, uv);
//             float4 albedoB = tex2D(_BAlbedo, uv);

//             float4 finalAlbedo = lerp(albedoA, albedoB, mask);

//             // Normals
//             float3 normalA = UnpackNormal(tex2D(_ANormal, uv));
//             float3 normalB = UnpackNormal(tex2D(_BNormal, uv));

//             float3 finalNormal =
//                 normalize(lerp(normalA, normalB, mask));

//             // MAOHS
//             float4 maohsA = tex2D(_AMAOHS, uv);
//             float4 maohsB = tex2D(_BMAOHS, uv);

//             float metallic =
//                 lerp(maohsA.r, _SnowMetallic, mask);

//             float ao =
//                 lerp(maohsA.g, _SnowAO, mask);

//             float smoothness =
//                 lerp(maohsA.a, _SnowSmoothness, mask);

//             // Output
//             o.Albedo = finalAlbedo.rgb;
//             o.Normal = finalNormal;

//             o.Metallic = metallic;
//             o.Smoothness = smoothness;
//             o.Occlusion = ao;
//         }

//         ENDCG
//     }

//     FallBack "Diffuse"
// }

Shader "Custom/VertexPaint_Final"
{
    Properties
    {
        // -------------------------------------------------
        // UV
        // -------------------------------------------------

        _UVScale ("UV Scale", Float) = 1

        // -------------------------------------------------
        // MATERIAL A
        // -------------------------------------------------

        [Header(Material A)]

        _AAlbedo ("A - Albedo", 2D) = "white" {}
        _ANormal ("A - Normal", 2D) = "bump" {}
        _AMask ("A - MAOHS", 2D) = "white" {}

        // -------------------------------------------------
        // MATERIAL B
        // -------------------------------------------------

        [Header(Material B)]

        _BAlbedo ("B - Albedo", 2D) = "white" {}
        _BNormal ("B - Normal", 2D) = "bump" {}
        _BMask ("B - MAOHS", 2D) = "white" {}

        // -------------------------------------------------
        // SNOW
        // -------------------------------------------------

        [Header(Snow)]

        _SnowAlbedo ("Snow - Albedo", 2D) = "white" {}
        _SnowNormal ("Snow - Normal", 2D) = "bump" {}
        _SnowMask ("Snow - MAOHS", 2D) = "white" {}

        // -------------------------------------------------
        // NOISE
        // -------------------------------------------------

        [Header(Noise)]

        _NoiseTexA ("Noise A", 2D) = "gray" {}
        _NoiseTexB ("Noise B", 2D) = "gray" {}

        _NoiseScaleA ("Noise Scale A", Float) = 1
        _NoiseScaleB ("Noise Scale B", Float) = 4

        // -------------------------------------------------
        // BLENDING
        // -------------------------------------------------

        [Header(Blend Settings)]

        _BlendDistance ("Blend Distance", Range(0.001,1)) = 0.2
        _SnowBlendDistance ("Snow Blend Distance", Range(0.001,1)) = 0.2

        // -------------------------------------------------
        // DISPLACEMENT
        // -------------------------------------------------

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

        // -------------------------------------------------
        // TEXTURES
        // -------------------------------------------------

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

        // -------------------------------------------------
        // VARIABLES
        // -------------------------------------------------

        float _UVScale;

        float _NoiseScaleA;
        float _NoiseScaleB;

        float _BlendDistance;
        float _SnowBlendDistance;

        float _DisplacementStrength;

        // -------------------------------------------------
        // INPUT
        // -------------------------------------------------

        struct Input
        {
            float2 uv_AAlbedo;
            float4 color : COLOR;
            float3 worldPos;
        };

        // -------------------------------------------------
        // VERTEX FUNCTION
        // -------------------------------------------------

        void vert(inout appdata_full v)
        {
            // BLUE CHANNEL = DISPLACEMENT

            float displacementMask = v.color.b;

            // Move vertices along normal

            v.vertex.xyz +=
                v.normal *
                displacementMask *
                _DisplacementStrength;
        }

        // -------------------------------------------------
        // SURFACE FUNCTION
        // -------------------------------------------------

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // -------------------------------------------------
            // UVs
            // -------------------------------------------------

            float2 uv = IN.uv_AAlbedo * _UVScale;

            // -------------------------------------------------
            // NOISES
            // -------------------------------------------------

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

            // -------------------------------------------------
            // VERTEX COLORS
            // -------------------------------------------------

            float vertexRed = IN.color.r;
            float vertexGreen = IN.color.g;

            // -------------------------------------------------
            // A/B BLEND MASK
            // -------------------------------------------------

            float blendAB =
                vertexRed +
                (combinedNoise - 0.5);

            blendAB = smoothstep(
                0.5 - _BlendDistance,
                0.5 + _BlendDistance,
                blendAB
            );

            // -------------------------------------------------
            // SNOW MASK
            // -------------------------------------------------

            float snowBlend =
                vertexGreen +
                (combinedNoise - 0.5);

            snowBlend = smoothstep(
                0.5 - _SnowBlendDistance,
                0.5 + _SnowBlendDistance,
                snowBlend
            );

            // -------------------------------------------------
            // MATERIAL A
            // -------------------------------------------------

            float4 albedoA =
                tex2D(_AAlbedo, uv);

            float3 normalA =
                UnpackNormal(
                    tex2D(_ANormal, uv)
                );

            float4 maskA =
                tex2D(_AMask, uv);

            // -------------------------------------------------
            // MATERIAL B
            // -------------------------------------------------

            float4 albedoB =
                tex2D(_BAlbedo, uv);

            float3 normalB =
                UnpackNormal(
                    tex2D(_BNormal, uv)
                );

            float4 maskB =
                tex2D(_BMask, uv);

            // -------------------------------------------------
            // BLEND A/B
            // -------------------------------------------------

            float4 baseAlbedo =
                lerp(albedoA, albedoB, blendAB);

            float3 baseNormal =
                normalize(
                    lerp(normalA, normalB, blendAB)
                );

            float4 baseMask =
                lerp(maskA, maskB, blendAB);

            // -------------------------------------------------
            // SNOW MATERIAL
            // -------------------------------------------------

            float4 snowAlbedo =
                tex2D(_SnowAlbedo, uv);

            float3 snowNormal =
                UnpackNormal(
                    tex2D(_SnowNormal, uv)
                );

            float4 snowMask =
                tex2D(_SnowMask, uv);

            // -------------------------------------------------
            // FINAL BLEND WITH SNOW
            // -------------------------------------------------

            float4 finalAlbedo =
                lerp(baseAlbedo, snowAlbedo, snowBlend);

            float3 finalNormal =
                normalize(
                    lerp(baseNormal, snowNormal, snowBlend)
                );

            float4 finalMask =
                lerp(baseMask, snowMask, snowBlend);

            // -------------------------------------------------
            // MASK MAP CHANNELS
            // R = Metallic
            // G = AO
            // B = Height
            // A = Smoothness
            // -------------------------------------------------

            float metallic = finalMask.r;
            float ao = finalMask.g;
            float height = finalMask.b;
            float smoothness = finalMask.a;

            // -------------------------------------------------
            // OUTPUT
            // -------------------------------------------------

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