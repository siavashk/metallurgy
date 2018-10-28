#include "morphology.h"
#import <Metal/Metal.h>

using namespace met;

namespace
{
    class MorphologyIOS : public Morphology
    {
    public:
        MorphologyIOS(
            const uint kernel
        ) {
            device_ = MTLCreateSystemDefaultDevice();
            kernelSize_ = kernel;
            buffer_ = [device_ newBufferWithBytes:&kernelSize_ length:4 options:MTLStorageModeShared];
            library_ = [device_ newDefaultLibrary];
            commandQueue_ = [device_ newCommandQueue];
            identityFunction_ = [library_ newFunctionWithName:@"identity"];
            pipelineState_ = [device_ newComputePipelineStateWithFunction:identityFunction_ error:NULL];
            commandBuffer_ = [commandQueue_ commandBuffer];
            commandEncoder_ = [commandBuffer_ computeCommandEncoder];
            [commandEncoder_ setComputePipelineState:pipelineState_];
        }

        virtual ~MorphologyIOS() override {}

        virtual std::shared_ptr<unsigned char> dilate(
            const std::shared_ptr<unsigned char>& inImage,
            const int width,
            const int height
        ) override {
            MTLTextureDescriptor* readDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormat::MTLPixelFormatR8Uint
                width:width height:height mipmapped:true];
            
            MTLTextureDescriptor* writeDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormat::MTLPixelFormatR8Uint
                width:width height:height mipmapped:true];

            [writeDesc setUsage:MTLTextureUsageShaderWrite];
            
            id<MTLTexture> inTexture = [device_ newTextureWithDescriptor:readDesc];
            id<MTLTexture> outTexture = [device_ newTextureWithDescriptor:writeDesc];
            
            MTLRegion entireImage = MTLRegionMake2D(0, 0, width, height);
            [inTexture replaceRegion:entireImage mipmapLevel:0 withBytes:reinterpret_cast<void*>(inImage.get()) bytesPerRow:height];
            
            [commandEncoder_ setTexture:inTexture atIndex:0];
            [commandEncoder_ setTexture:outTexture atIndex:1];
            [commandEncoder_ setBuffer:buffer_ offset:0 atIndex:0];
            
            MTLSize threadGroupCount = MTLSizeMake(5, 5, 1);
            MTLSize threadGroups = MTLSizeMake(inTexture.width / threadGroupCount.width,
                inTexture.height / threadGroupCount.height, 1);
            
            [commandEncoder_ dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
            [commandEncoder_ endEncoding];
            [commandBuffer_ commit];
            [commandBuffer_ waitUntilCompleted];
            
            void* result = malloc(width * height);
            
            [outTexture getBytes:result bytesPerRow:width fromRegion:entireImage mipmapLevel:0];
            
            std::shared_ptr<unsigned char> outImage;
            outImage.reset(reinterpret_cast<unsigned char*>(result));
            
            return outImage;
        }

    private:
        id<MTLDevice> device_;
        uint kernelSize_;
        id<MTLBuffer> buffer_;
        id<MTLLibrary> library_;
        id<MTLComputePipelineState> pipelineState_;
        id<MTLCommandQueue> commandQueue_;
        id<MTLFunction> identityFunction_;
        id<MTLCommandBuffer> commandBuffer_;
        id<MTLComputeCommandEncoder> commandEncoder_;
    };
}

met::Morphology::~Morphology()
{
}

std::unique_ptr<Morphology> met::createMorphology(
    const uint kernelSize
) {
    return std::make_unique<MorphologyIOS>(kernelSize);
}
