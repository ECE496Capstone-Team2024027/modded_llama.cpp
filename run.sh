#!/bin/bash

# USAGE
# Run without architectural acceleration, no fpga
#   > bash run.sh nofpga
# Run with architectural acceleration, with fpga
#   > bash run.sh fpga

# default run config
RUN_OPT="nofpga"
# RUN_OPT="fpga"

# Check if a command-line argument is passed and override RUN_OPT
if [ "$#" -eq 0 ]; then
    echo "*** No arguments provided. Using default RUN_OPT: $RUN_OPT ***"
else
    for arg in "$@"; do
        case $arg in
            "fpga"|"nofpga")
                RUN_OPT="$arg"
                ;;
            *)
                echo "Unknown option: $arg"
                exit 1
                ;;
        esac
    done
fi

MODEL="./dir/to/model.gguf"
SEED=314
# If dumping out dotp info (default off), then use NUMGEN=1
NUMGEN=10
MODEL_PROMPT="Once upon a time there was a fox who "

./build_${RUN_OPT}/bin/llama-cli -t 1 -m "$MODEL" -s "$SEED" -n "$NUMGEN" -e -p "$MODEL_PROMPT" # running with 1 thread
