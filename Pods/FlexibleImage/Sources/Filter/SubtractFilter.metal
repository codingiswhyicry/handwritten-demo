//
//  SubtractFilter.metal
//  Test Project
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void SubtractFilter(
                           texture2d<float, access::write> outTexture [[texture(0)]],
                           texture2d<float, access::read> inTexture [[texture(1)]],
                           const device float *colorRed [[buffer(0)]],
                           const device float *colorGreen [[buffer(1)]],
                           const device float *colorBlue [[buffer(2)]],
                           const device float *colorAlpha [[buffer(3)]],
                           uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    const float4 adjustColor = float4(*colorRed, *colorGreen, *colorBlue, *colorAlpha);
    
    const float4 outColor = max(inColor - adjustColor, 0.0);
    outTexture.write(outColor, gid);
}
