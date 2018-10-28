#include <morphology.h>
#include <iostream>
#include <chrono>
#include <ctime>

using namespace met;

namespace
{
    bool isWhite(
        const int row,
        const int col,
        const int kernel,
        const int length
    ) {
        return (length - kernel) / 2 <= row && (length + kernel) / 2 > row &&
            (length - kernel) / 2 <= col && (length + kernel) / 2 > col;
    }
    unsigned char* makeSquare(
        const int kernel,
        const int length
    ) {
        if (length < 0 || kernel < 0 || length < kernel || length % 2 == 0 || kernel % 2 == 0)
            throw std::runtime_error("Invalid length or kernel size supplied");
        
        unsigned char* pixels = (unsigned char*)malloc(length * length);
        
        for (int i=0; i < length; i++)
        {
            for (int j=0; j < length; j++)
            {
                if (isWhite(i, j, kernel, length))
                    *(pixels + i * length + j) = 1;
                else
                    *(pixels + i * length + j) = 0;
            }
        }
        return pixels;
    }
    void print(
        const unsigned char* pixels,
        const int length
    ) {
        for (int i=0; i < length; i++)
        {
            for (int j=0; j < length; j++)
                std::cout << int(*(pixels + i * length + j)) << ", ";
            std::cout << std::endl;
        }
    }
}

int main(int argc, char* argv[])
{
    auto morph = createMorphology(3);
    
    const int length = 1001;
    const int kernel = 3;
    
    unsigned char* pixels = makeSquare(kernel, length);

    std::shared_ptr<unsigned char> image;
    image.reset(pixels);
    
    auto start = std::chrono::system_clock::now();
    for (int i=0; i < 1000; i++)
        morph->dilate(image, length, length);
    auto end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsedSeconds = end - start;
    
    std::cout << "Dilation took approximately " << elapsedSeconds.count() / 1000 << " (sec)." << std::endl;

    return EXIT_SUCCESS;
}
