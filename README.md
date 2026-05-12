# llama.cpp-portable

Build **[llama.cpp](https://github.com/ggml-org/llama.cpp)** on **Ubuntu 24.04 (amd64)** with **Vulkan**, **ROCm (HIP)**, and **CUDA**, install each backend under a shared prefix, bundle needed shared libraries (rpath + copies), and emit one **`llama.cpp-portable-v*-linux-x86_64.tar.xz`** in the repo root. That archive is a relocatable tree, not a single static binary.

**Defaults (edit the `0x` scripts if your hardware differs):** ROCm targets **`gfx1151,gfx1152`**; CUDA **`CMAKE_CUDA_ARCHITECTURES=120a-real`** (Blackwell-class). Other GPUs need different flags.

## How to get a build

**GitHub Actions:** run workflow **Build** manually ([`.github/workflows/build.yml`](.github/workflows/build.yml)). Optional inputs set the llama.cpp **git URL** and **branch / tag / commit** (defaults: upstream repo and `master`). The workflow uploads the tarball as an **artifact** and creates a **release** using the version stamped in `pkginfo.txt` during the build.

**Same pipeline on a machine:** from the repo root, as root:

```sh
sudo ./00-build-dependencies.sh
sudo ./01-build-vulkan.sh
sudo ./02-build-rocm.sh
sudo ./03-build-cuda.sh
sudo ./04-finalize.sh
```

`00-build-dependencies.sh` accepts optional `[repo] [ref]`; if you omit them, it uses upstream **https://github.com/ggml-org/llama.cpp** and **`master`**. The tarball and **`pkginfo.txt`** (build metadata, gitignored) land in the repo root beside the scripts.

**Docker on the host:** [`build-in-docker.sh`](build-in-docker.sh) builds `docker/` and runs `00`–`04` inside a persistent container with the repo bind-mounted at `/work`.
