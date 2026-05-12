#!/bin/sh

set -eu

ME="$(readlink -f "$0")"
MY_DIR="$(dirname "$ME")"

REPO="${1:-"https://github.com/ggml-org/llama.cpp"}"
REF="${2:-"master"}"

# REPO="https://github.com/TheTom/llama-cpp-turboquant"
# REF="feature/turboquant-kv-cache"

# REPO="https://github.com/am17an/llama.cpp"
# REF="mtp-clean"

apt-get update

apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    glslang-tools \
    glslc \
    libibverbs-dev \
    libssl-dev \
    libvulkan-dev \
    ninja-build \
    patchelf \
    python3-venv \
    spirv-headers \
    vulkan-tools

curl -fsSLo /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
apt-get install -y /tmp/cuda-keyring.deb

apt-get update

apt-get install -y \
    cuda-toolkit \
    libnccl-dev

if [ ! -d /tmp/rocm-rock ]; then
    python3 -m venv /tmp/rocm-rock
fi

# shellcheck source=/dev/null
. /tmp/rocm-rock/bin/activate

pip install -U --no-cache-dir pip

pip install -U --no-cache-dir --index-url https://rocm.nightlies.amd.com/whl-multi-arch \
    "rocm[libraries,devel,device-gfx1151,device-gfx1152]"

rm -rf /tmp/llama.cpp

git clone "$REPO" /tmp/llama.cpp

cd /tmp/llama.cpp

if git checkout --detach "$REF"; then
    :
else
    git fetch origin "$REF"
    git checkout --detach FETCH_HEAD
fi

VERSION="v$(date +%Y%m%d%H%M)"
NAME="llama.cpp-portable-$VERSION-linux-x86_64.tar.xz"
COMMIT="$(git rev-parse HEAD)"
ROCM_VERSION="$(pip freeze | sed -n 's/^rocm==//p' | head -n1)"
CUDA_NVCC_BUILD="$(/usr/local/cuda/bin/nvcc --version | sed -n 's/^Build //p' | head -n1)"
VULKAN_SHADERC_VERSION="$(glslc --version | sed -n 's/^shaderc //p' | head -n1)"
VULKAN_SPIRV_TOOLS_VERSION="$(glslc --version | sed -n 's/^spirv-tools //p' | head -n1)"
VULKAN_GLSLANG_PKG_VERSION="$(glslc --version | sed -n 's/^glslang //p' | head -n1)"
VULKAN_GLSLANG_VERSION="$(glslangValidator --version | sed -n 's/^Glslang Version: //p' | head -n1)"

{
    printf 'NAME="%s"\n' "$NAME"
    printf 'VERSION="%s"\n' "$VERSION"
    printf 'REPO="%s"\n' "$REPO"
    printf 'REF="%s"\n' "$REF"
    printf 'COMMIT="%s"\n' "$COMMIT"
    printf 'ROCM_VERSION="%s"\n' "$ROCM_VERSION"
    printf 'CUDA_NVCC_BUILD="%s"\n' "$CUDA_NVCC_BUILD"
    printf 'VULKAN_SHADERC_VERSION="%s"\n' "$VULKAN_SHADERC_VERSION"
    printf 'VULKAN_SPIRV_TOOLS_VERSION="%s"\n' "$VULKAN_SPIRV_TOOLS_VERSION"
    printf 'VULKAN_GLSLANG_PKG_VERSION="%s"\n' "$VULKAN_GLSLANG_PKG_VERSION"
    printf 'VULKAN_GLSLANG_VERSION="%s"\n' "$VULKAN_GLSLANG_VERSION"
} >"$MY_DIR/pkginfo.txt"
