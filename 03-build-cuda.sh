#!/bin/sh

set -eu

INSTALL_PREFIX="/tmp/build/llama.cpp/cuda"

cd /tmp/llama.cpp

git reset --hard
git clean -dfx
git submodule foreach --recursive git clean -dfx

export PATH="/usr/local/cuda/bin:$PATH"

cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES=120a-real \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DGGML_ACCELERATE=OFF \
    -DGGML_CCACHE=OFF \
    -DGGML_CUDA=ON \
    -DGGML_OPENMP=ON \
    -DGGML_RPC_RDMA=ON \
    -DGGML_RPC=ON \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF

cmake --build build -j "$(nproc --ignore 2)" --target llama-diffusion-cli
cmake --install build --strip
