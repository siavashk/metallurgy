
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
            const std::shared_ptr<unsigned char>& image,
            const int width,
            const int height
        ) = 0;
    };

    std::unique_ptr<Morphology> createMorphology();
}
