#!/bin/bash

# DEPENDENCY
# Ninja: build config in cmake for llama.cpp
#    Option to avoid this build config using flag "-noninja" for this script

# USAGE
# Compile without architectural acceleration, no fpga
#   > bash build_run.sh nofpga [-noninja]
# Compile without architectural acceleration, with fpga
#   > bash build_run.sh fpga [-noninja]

# default build config
BUILD_OPT="nofpga"
# BUILD_OPT="fpga"
NO_NINJA=false
DO_BUILD=true
DO_RUN=true

# Check if a command-line argument is passed and override BUILD_OPT
if [ "$#" -eq 0 ]; then
    echo "*** No arguments provided. Using default BUILD_OPT: $BUILD_OPT"
else
    for arg in "$@"; do
        case $arg in
            "fpga"|"nofpga")
                BUILD_OPT="$arg"
                ;;
            "-skipbuild")
                DO_BUILD=false
                ;;
            "-skiprun")
                DO_RUN=false
                ;;
            "-noninja")
                NO_NINJA=true
                ;;
            *)
                echo "Unknown option: $arg"
                exit 1
                ;;
        esac
    done
fi

if [ "$DO_BUILD" = true ]; then
    rm -rf build_${BUILD_OPT}

    if [ "$NO_NINJA" = true ]; then
        USE_FPGA="OFF"
        if [ "$BUILD_OPT" = "fpga" ]; then
            USE_FPGA="ON"
        fi
        
        mkdir build_${BUILD_OPT}
        cd build_${BUILD_OPT}
        cmake .. -DCMAKE_C_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3" \
                    -DCMAKE_CXX_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3" \
                    -DGGML_METAL=OFF -DGGML_BLAS=OFF -DGGML_LLAMAFILE=OFF \
                    -DGGML_COMPILER_SUPPORT_MATMUL_INT8=OFF -DGGML_COMPILER_SUPPORT_FP16_VECTOR_ARITHMETIC=OFF \
                    -DGGML_COMPILER_SUPPORT_DOTPROD=OFF -DGGML_NATIVE=OFF -DGGML_ACCELERATE=OFF -DGGML_SIMD=OFF \
                    -DFPGA_ACCELERATOR=$USE_FPGA
        make
        cd ..
    else
        cmake --preset ${BUILD_OPT}
        cmake --build --preset ${BUILD_OPT}
    fi
fi # dobuild

if [ "$DO_RUN" = true ]; then
    MODEL="./dir/to/model.gguf"
    SEED=315
    # If dumping out dotp info (default off), then use NUMGEN=1
    NUMGEN=10
    MODEL_PROMPT="Once upon a time there was a fox who "

    ./build_${BUILD_OPT}/bin/llama-cli -t 1 -m "$MODEL" -s "$SEED" -n "$NUMGEN" -e -p "$MODEL_PROMPT" # running with 1 thread
fi # dorun