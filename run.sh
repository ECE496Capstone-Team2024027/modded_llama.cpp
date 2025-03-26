#!/bin/bash

# USAGE
# Run without architectural acceleration, no fpga
#   > bash run.sh nofpga
# Run with architectural acceleration, with fpga
#   > bash run.sh fpga

# OPTIONS
# -prompt <"custom string prompt">
# -numgen <Number of tokens to generate>

# default run config
RUN_OPT="nofpga"
# RUN_OPT="fpga"

MODEL="./dir/to/model.gguf"
SEED=314
# If dumping out dotp info (default off), then use NUMGEN=1
NUMGEN=10
MODEL_PROMPT="Once upon a time there was a fox who "

# Check if a command-line argument is passed and override RUN_OPT or MODEL_PROMPT
if [ "$#" -eq 0 ]; then
    echo "*** No arguments provided. Using default RUN_OPT: $RUN_OPT ***"
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            "fpga"|"nofpga")
                RUN_OPT="$1"
                shift
                ;;
            "-prompt")
                if [[ -n "$2" ]]; then
                    MODEL_PROMPT="$2"
                    shift 2
                else
                    echo "Error: -prompt requires a string argument"
                    exit 1
                fi
                ;;
            "-numgen")
                if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                    NUMGEN="$2"
                    shift 2
                else
                    echo "Error: -gennum requires a numeric argument"
                    exit 1
                fi
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
fi

./build_${RUN_OPT}/bin/llama-cli -t 1 -m "$MODEL" -s "$SEED" -n "$NUMGEN" -e -p "$MODEL_PROMPT" # running with 1 thread
