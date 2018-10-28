project(metallurgy)

set(HEADER_FILES
    morphology.h
)

set(SOURCE_FILES
    morphology.mm
    # shaders.metal
)

add_library(metallurgy
    STATIC
    ${HEADER_FILES}
    ${SOURCE_FILES}
    # ${METAL_SHADERS}
)
