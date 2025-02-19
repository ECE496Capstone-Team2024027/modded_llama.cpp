#!/bin/bash

# DEPENDENCY
# Ninja: build config in cmake for llama.cpp
#    Option to avoid this build config using flag "-noninja" for this script

# USAGE
# Compile without architectural acceleration, no fpga
#   > bash build_run.sh nofpga [options]
# Compile with architectural acceleration, with fpga
#   > bash build_run.sh fpga [options]

# OPTION SHORTHANDS
#   -discokit
#       MUST USE THIS OPTION FOR DISCO KIT. It includes options -noninja, and -useswap
#
# BUILD OPTIONS
#   -noninja
#       Bypass build config in cmake for llama.cpp, which uses NINJA
#   -useswap
#       Sets up swap memory to use for compilation, use for memory constrained devices like the MPFS Disco Kit

# default build config
BUILD_OPT="nofpga"
# BUILD_OPT="fpga"
NO_NINJA=false
USE_SWAP=false  # this option is required for the DISCO KIT
COMPILE_DISCOKIT=false

# Check if a command-line argument is passed and override BUILD_OPT
if [ "$#" -eq 0 ]; then
    echo "*** No arguments provided. Using default BUILD_OPT: $BUILD_OPT ***"
else
    for arg in "$@"; do
        case $arg in
            "fpga"|"nofpga")
                BUILD_OPT="$arg"
                ;;
            "-useswap")
                USE_SWAP=true
                ;;
            "-noninja")
                NO_NINJA=true
                ;;
            "-discokit")
                NO_NINJA=true
                USE_SWAP=true
                COMPILE_DISCOKIT=true
                ;;
            *)
                echo "Unknown option: $arg"
                exit 1
                ;;
        esac
    done
fi

if [ "$USE_SWAP" = true ]; then
    echo "*** USING SWAP MEMORY TO COMPILE ***"
    dd if=/dev/zero of=/swapfile bs=1M count=1024
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
fi

rm -rf build_${BUILD_OPT}

if [ "$NO_NINJA" = true ]; then
    USE_FPGA="OFF"
    if [ "$BUILD_OPT" = "fpga" ]; then
        USE_FPGA="ON"
    fi

    COMPILE_CMAKE_FLAGS=
    if [ "$COMPILE_DISCOKIT" = false ]; then
        echo "*** BUILDING WITH DISCOKIT OPTIONS ***"
        COMPILE_CMAKE_FLAGS=true
    fi

    mkdir build_${BUILD_OPT}
    cd build_${BUILD_OPT}
    cmake .. ${COMPILE_WITH_FLAGS:+-DCMAKE_C_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3"} \
             ${COMPILE_WITH_FLAGS:+-DCMAKE_CXX_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3"} \
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
