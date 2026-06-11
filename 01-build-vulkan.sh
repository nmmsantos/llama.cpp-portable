#!/bin/sh

set -eu

INSTALL_PREFIX="/tmp/build/llama.cpp/vulkan"

cd /tmp/llama.cpp

git reset --hard
git clean -dfx
git submodule foreach --recursive git clean -dfx

cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DGGML_ACCELERATE=OFF \
    -DGGML_CCACHE=OFF \
    -DGGML_OPENMP=ON \
    -DGGML_RPC_RDMA=ON \
    -DGGML_RPC=ON \
    -DGGML_VULKAN=ON \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF

cmake --build build -j "$(nproc --ignore 2)" --target llama-diffusion-cli
cmake --install build --strip
