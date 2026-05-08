#ifndef SCANNER_WORLD_POSITION_INCLUDED
#define SCANNER_WORLD_POSITION_INCLUDED

void GetWorldPosition_float(float2 UV, out float3 WorldPos)
{
#if defined(SHADERGRAPH_PREVIEW)
    WorldPos = float3(0.0, 0.0, 0.0);
#else
    float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV);

#if UNITY_REVERSED_Z
    float rawDepth = depth;
#else
    float rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1.0, depth);
#endif

    WorldPos = ComputeWorldSpacePosition(UV, rawDepth, UNITY_MATRIX_I_VP);
#endif
}

void GetWorldPosition_half(half2 UV, out half3 WorldPos)
{
#if defined(SHADERGRAPH_PREVIEW)
    WorldPos = half3(0.0, 0.0, 0.0);
#else
    float3 worldPosFloat;
    GetWorldPosition_float((float2) UV, worldPosFloat);
    WorldPos = (half3) worldPosFloat;
#endif
}

#endif