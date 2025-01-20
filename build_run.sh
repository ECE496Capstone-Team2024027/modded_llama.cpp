rm -rf build_offall
mkdir build_offall
cd build_offall
cmake .. -DCMAKE_C_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3" -DCMAKE_CXX_FLAGS="-mno-avx2 -mno-avx -mno-fma -mno-sse3 -mno-ssse3" -DGGML_METAL=OFF -DGGML_BLAS=OFF -DGGML_LLAMAFILE=OFF -DGGML_COMPILER_SUPPORT_MATMUL_INT8=OFF -DGGML_COMPILER_SUPPORT_FP16_VECTOR_ARITHMETIC=OFF -DGGML_COMPILER_SUPPORT_DOTPROD=OFF -DGGML_NATIVE=OFF -DGGML_ACCELERATE=OFF -DGGML_SIMD=OFF
make

MODEL="./dir/to/model.gguf"
SEED=315
NUMGEN=1
MODEL_PROMPT="Once upon a time there was a fox who "
./bin/llama-cli -t 1 -m "$MODEL" -s "$SEED" -n "$NUMGEN" -e -p "$MODEL_PROMPT" # running with 1 thread