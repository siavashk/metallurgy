
#pragma once
#include <memory>
#include <iostream>

namespace met
{
    class Morphology
    {
    public:
        virtual ~Morphology() = 0;

        virtual std::shared_ptr<unsigned char> dilate(
            const std::shared_ptr<unsigned char>& image
        ) = 0;
        
        virtual std::shared_ptr<unsigned char> erode(
            const std::shared_ptr<unsigned char>& image
        ) = 0;
    };

    std::unique_ptr<Morphology> createMorphology(
        const uint kernelSize,
        const uint width,
        const uint height
    );
}
