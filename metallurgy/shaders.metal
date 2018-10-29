#include <metal_stdlib>

using namespace metal;

kernel void dilation(
    texture2d<uint, access::read> inTexture [[texture(0)]],
    texture2d<uint, access::write> outTexture [[texture(1)]],
    device uint *kernelSize [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    uint halfKernel = kernelSize[0] / 2;
    uint minX = gid.x >= halfKernel ? gid.x - halfKernel : 0;
    uint minY = gid.y >= halfKernel ? gid.y - halfKernel : 0;
    uint maxX = gid.x + halfKernel < inTexture.get_width() ? gid.x + halfKernel : inTexture.get_width();
    uint maxY = gid.y + halfKernel < inTexture.get_height() ? gid.y + halfKernel : inTexture.get_height();
    uint maxValue = 0;
    for (uint i = minX; i <= maxX; i++)
    {
        for (uint j = minY; j <= maxY; j++)
        {
            uint4 value = inTexture.read(uint2(i, j));
            if (maxValue < value[0])
                maxValue = value[0];
        }
    }
    outTexture.write(maxValue, gid);
}

kernel void erosion(
    texture2d<uint, access::read> inTexture [[texture(0)]],
    texture2d<uint, access::write> outTexture [[texture(1)]],
    device uint *kernelSize [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    uint halfKernel = kernelSize[0] / 2;
    uint minX = gid.x >= halfKernel ? gid.x - halfKernel : 0;
    uint minY = gid.y >= halfKernel ? gid.y - halfKernel : 0;
    uint maxX = gid.x + halfKernel < inTexture.get_width() ? gid.x + halfKernel : inTexture.get_width();
    uint maxY = gid.y + halfKernel < inTexture.get_height() ? gid.y + halfKernel : inTexture.get_height();
    uint minValue = inTexture.read(gid)[0];
    for (uint i = minX; i <= maxX; i++)
    {
        for (uint j = minY; j <= maxY; j++)
        {
            uint4 value = inTexture.read(uint2(i, j));
            if (minValue > value[0])
                minValue = value[0];
        }
    }
    outTexture.write(minValue, gid);
}
