#!/bin/sh

set -eu

INSTALL_PREFIX="/tmp/build/llama.cpp/rocm"

cd /tmp/llama.cpp

git reset --hard
git clean -dfx
git submodule foreach --recursive git clean -dfx

# shellcheck source=/dev/null
. /tmp/rocm-rock/bin/activate

ROCM_PATH="$(hipconfig -R)"
HIP_CLANG_PATH="$(hipconfig -l)"

export ROCM_PATH

# FIXME: this is a hack to force the use of gfx1151 instead of gfx1152
sed -i '/^void common_init() {/a\
    setenv("HSA_OVERRIDE_GFX_VERSION", "11.5.1", 0);
' common/common.cpp

cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="$HIP_CLANG_PATH/clang" \
    -DCMAKE_CXX_COMPILER="$HIP_CLANG_PATH/clang++" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DGGML_ACCELERATE=OFF \
    -DGGML_CCACHE=OFF \
    -DGGML_HIP_ROCWMMA_FATTN=ON \
    -DGGML_HIP=ON \
    -DGGML_OPENMP=ON \
    -DGGML_RPC_RDMA=ON \
    -DGGML_RPC=ON \
    -DGPU_TARGETS=gfx1151,gfx1152 \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_TESTS=OFF

cmake --build build -j "$(nproc --ignore 2)"
cmake --install build --strip
