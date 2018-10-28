#include <metal_stdlib>

using namespace metal;

kernel void identity(
    texture2d<uint, access::read> inTexture [[texture(0)]],
    texture2d<uint, access::write> outTexture [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    outTexture.write(inTexture.read(gid), gid);
}
