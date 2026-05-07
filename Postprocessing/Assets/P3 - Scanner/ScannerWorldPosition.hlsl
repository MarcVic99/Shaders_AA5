#ifndef SCANNER_WORLD_POSITION_INCLUDED
#define SCANNER_WORLD_POSITION_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

void GetWorldPosition_float(float2 UV, out float3 WorldPos)
{
    float depth = SampleSceneDepth(UV);

#if UNITY_REVERSED_Z
    float rawDepth = depth;
#else
    float rawDepth = lerp(UNITY_NEAR_CLIP_VALUE, 1.0, depth);
#endif

    WorldPos = ComputeWorldSpacePosition(UV, rawDepth, UNITY_MATRIX_I_VP);
}

#endif