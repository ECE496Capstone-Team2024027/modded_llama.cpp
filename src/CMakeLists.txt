# TODO: should not use this
if (WIN32)
    if (BUILD_SHARED_LIBS)
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()
endif()

llama_add_compile_flags()

#
# libraries
#


# llama

add_library(llama
../include/llama.h
llama.cpp
llama-vocab.cpp
llama-grammar.cpp
llama-sampling.cpp
unicode.h
unicode.cpp
unicode-data.cpp
)

if (FPGA_ACCELERATOR)
    target_link_libraries(llama PRIVATE accelerator)
    target_include_directories(llama PRIVATE ${ACCELERATOR_INCLUDE_DIR})
    target_compile_definitions(llama PRIVATE USE_FPGA_API)
endif()

target_include_directories(llama PUBLIC . ../include)
target_compile_features   (llama PUBLIC cxx_std_17) # don't bump

target_link_libraries(llama PUBLIC ggml)

if (BUILD_SHARED_LIBS)
    set_target_properties(llama PROPERTIES POSITION_INDEPENDENT_CODE ON)
    target_compile_definitions(llama PRIVATE LLAMA_BUILD)
    target_compile_definitions(llama PUBLIC  LLAMA_SHARED)
endif()
