//
//  ContrastFilter.metal
//  Test Project
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void ContrastFilter(
                           texture2d<float, access::write> outTexture [[texture(0)]],
                           texture2d<float, access::read> inTexture [[texture(1)]],
                           const device float *contrast [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    const float4 outColor = float4((inColor.rgb - float3(0.5)) * *contrast + float3(0.5), inColor.a);
    outTexture.write(outColor, gid);
}
