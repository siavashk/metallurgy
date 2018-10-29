#include <morphology.h>

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
}

int main(int argc, char* argv[])
{
    const int background = 1001;
    const int foreground = 7;
    const int kernel = 3;

    auto morph = createMorphology(kernel, background, background);

    unsigned char* pixels = makeSquare(foreground, background);

    std::shared_ptr<unsigned char> image;
    image.reset(pixels);

    const int samples = 10000;
    auto start = std::chrono::system_clock::now();
    for (int i=0; i < samples; i++)
        morph->dilate(image);
    auto end = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsedSeconds = end - start;

    std::cout << "Dilation took approximately " << elapsedSeconds.count() / samples << " (sec)." << std::endl;

    return EXIT_SUCCESS;
}
