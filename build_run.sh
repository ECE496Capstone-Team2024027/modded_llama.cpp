#!/bin/bash

# USAGE
# Compile without architectural acceleration, no fpga
#   > bash build_run.sh nofpga
# Compile without architectural acceleration, with fpga
#   > bash build_run.sh fpga

# default build config
BUILD_OPT="nofpga"
# BUILD_OPT="fpga"

# Check if a command-line argument is passed and override BUILD_OPT
if [ $# -gt 0 ]; then
    case $1 in
        "fpga")
            BUILD_OPT="fpga"
            ;;
        "nofpga")
            BUILD_OPT="nofpga"
            ;;
        *)
            echo "Unknown option: $1. Using default value: $BUILD_OPT"
            ;;
    esac
else
    echo "No command-line argument passed. Using default value: $BUILD_OPT"
fi

rm -rf build_${BUILD_OPT}
cmake --preset ${BUILD_OPT}
cmake --build --preset ${BUILD_OPT}

MODEL="./dir/to/model.gguf"
SEED=315
NUMGEN=1
MODEL_PROMPT="Once upon a time there was a fox who "

./build_${BUILD_OPT}/bin/llama-cli -t 1 -m "$MODEL" -s "$SEED" -n "$NUMGEN" -e -p "$MODEL_PROMPT" # running with 1 thread
