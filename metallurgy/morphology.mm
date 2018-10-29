#include "morphology.h"
#import <Metal/Metal.h>

using namespace met;

namespace
{
    class MorphologyIOS : public Morphology
    {
    public:
        MorphologyIOS(
            const uint kernel,
            const uint width,
            const uint height
        ) {
            device_ = MTLCreateSystemDefaultDevice();
            kernelSize_ = kernel;
            buffer_ = [device_ newBufferWithBytes:&kernelSize_ length:4 options:MTLStorageModeShared];
            library_ = [device_ newDefaultLibrary];
            commandQueue_ = [device_ newCommandQueue];
            dilationFunction_ = [library_ newFunctionWithName:@"dilation"];
            erosionFunction_ = [library_ newFunctionWithName:@"erosion"];
            
            MTLTextureDescriptor* readDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormat::MTLPixelFormatR8Uint
                width:width height:height mipmapped:false];
            
            MTLTextureDescriptor* writeDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormat::MTLPixelFormatR8Uint
                width:width height:height mipmapped:false];
            
            [writeDesc setUsage:MTLTextureUsageShaderWrite];
            
            inTexture_ = [device_ newTextureWithDescriptor:readDesc];
            outTexture_ = [device_ newTextureWithDescriptor:writeDesc];
            
            entireImage_ = MTLRegionMake2D(0, 0, width, height);
            
            dilatePipelineState_ = [device_ newComputePipelineStateWithFunction:dilationFunction_ error:NULL];
            erodePipelineState_ = [device_ newComputePipelineStateWithFunction:erosionFunction_ error:NULL];
        }

        virtual ~MorphologyIOS() override {}

        virtual std::shared_ptr<unsigned char> dilate(
            const std::shared_ptr<unsigned char>& inImage
        ) override {
            void* result = malloc(outTexture_.width * outTexture_.height);
            std::shared_ptr<unsigned char> outImage;
            @autoreleasepool
            {
                commandBuffer_ = [commandQueue_ commandBuffer];
                commandEncoder_ = [commandBuffer_ computeCommandEncoder];
                [commandEncoder_ setComputePipelineState:dilatePipelineState_];

                [inTexture_ replaceRegion:entireImage_ mipmapLevel:0 withBytes:inImage.get() bytesPerRow:outTexture_.width];

                [commandEncoder_ setTexture:inTexture_ atIndex:0];
                [commandEncoder_ setTexture:outTexture_ atIndex:1];
                [commandEncoder_ setBuffer:buffer_ offset:0 atIndex:0];

                MTLSize threadGroupCount = MTLSizeMake(16, 16, 1);
                MTLSize threadGroups = MTLSizeMake(inTexture_.width / threadGroupCount.width,
                    inTexture_.height / threadGroupCount.height, 1);

                [commandEncoder_ dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
                [commandEncoder_ endEncoding];
                [commandBuffer_ commit];
                [commandBuffer_ waitUntilCompleted];

                [outTexture_ getBytes:result bytesPerRow:outTexture_.width fromRegion:entireImage_ mipmapLevel:0];
                outImage.reset(reinterpret_cast<unsigned char*>(result));
            }

            return outImage;
        }
        
        virtual std::shared_ptr<unsigned char> erode(
            const std::shared_ptr<unsigned char>& inImage
        ) override {
            void* result = malloc(outTexture_.width * outTexture_.height);
            std::shared_ptr<unsigned char> outImage;
            @autoreleasepool
            {
                commandBuffer_ = [commandQueue_ commandBuffer];
                commandEncoder_ = [commandBuffer_ computeCommandEncoder];
                [commandEncoder_ setComputePipelineState:erodePipelineState_];

                [inTexture_ replaceRegion:entireImage_ mipmapLevel:0 withBytes:inImage.get() bytesPerRow:outTexture_.width];

                [commandEncoder_ setTexture:inTexture_ atIndex:0];
                [commandEncoder_ setTexture:outTexture_ atIndex:1];
                [commandEncoder_ setBuffer:buffer_ offset:0 atIndex:0];

                MTLSize threadGroupCount = MTLSizeMake(16, 16, 1);
                MTLSize threadGroups = MTLSizeMake(inTexture_.width / threadGroupCount.width,
                    inTexture_.height / threadGroupCount.height, 1);

                [commandEncoder_ dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
                [commandEncoder_ endEncoding];
                [commandBuffer_ commit];
                [commandBuffer_ waitUntilCompleted];

                [outTexture_ getBytes:result bytesPerRow:outTexture_.width fromRegion:entireImage_ mipmapLevel:0];
                outImage.reset(reinterpret_cast<unsigned char*>(result));
            }

            return outImage;
        }

    private:
        id<MTLDevice> device_;
        uint kernelSize_;
        id<MTLBuffer> buffer_;
        id<MTLLibrary> library_;
        id<MTLComputePipelineState> dilatePipelineState_;
        id<MTLComputePipelineState> erodePipelineState_;
        id<MTLCommandQueue> commandQueue_;
        id<MTLFunction> dilationFunction_;
        id<MTLFunction> erosionFunction_;
        id<MTLCommandBuffer> commandBuffer_;
        id<MTLComputeCommandEncoder> commandEncoder_;
        id<MTLTexture> inTexture_;
        id<MTLTexture> outTexture_;
        MTLRegion entireImage_;
    };
}

met::Morphology::~Morphology()
{
}

std::unique_ptr<Morphology> met::createMorphology(
    const uint kernelSize,
    const uint width,
    const uint height
) {
    return std::make_unique<MorphologyIOS>(kernelSize, width, height);
}
