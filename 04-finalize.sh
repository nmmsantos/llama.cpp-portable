#!/bin/sh

set -eu

ME="$(readlink -f "$0")"
MY_DIR="$(dirname "$ME")"
INSTALL_PREFIX="/tmp/build/llama.cpp"

find "$INSTALL_PREFIX" -type f -path '*/bin/*' \
    -exec patchelf --set-rpath \$'ORIGIN/../lib:'\$'ORIGIN/../../lib' {} \; \
    2>/dev/null

find "$INSTALL_PREFIX" -type f -path '*/lib/*' \
    -exec patchelf --set-rpath \$'ORIGIN:'\$'ORIGIN/../../lib' {} \; \
    2>/dev/null

# shellcheck source=/dev/null
. /tmp/rocm-rock/bin/activate

ROCM_PATH="$(hipconfig -R)"

deactivate

EXCLUDE_LIBS="^$INSTALL_PREFIX\
\|/libc\.so\.6$\
\|/libcuda\.so\.1$\
\|/libdl\.so\.2$\
\|/libm\.so\.6$\
\|/libpthread\.so\.0$\
\|/librt\.so\.1$\
\|/libvulkan\.so\.1$"

mkdir -p "$INSTALL_PREFIX/lib/libibverbs"

LD_LIBRARY_PATH="$ROCM_PATH/lib:$ROCM_PATH/lib/llvm/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" find "$INSTALL_PREFIX" -type f -path '*/bin/*' \
    -exec ldd {} + 2>/dev/null \
| sed -n 's/.*=> \(.*\) (.*/\1/p' \
| grep -v "$EXCLUDE_LIBS" \
| sort -u \
| xargs -rI{} sh -euc '
    src="'\$'1"
    dst="'\$'2/'\$'(basename "'\$'src")"
    cp -LT "'\$'src" "'\$'dst"
    patchelf --set-rpath '\'''\$'ORIGIN'\'' "'\$'dst"
' sh {} "$INSTALL_PREFIX/lib"

cp -at "$INSTALL_PREFIX/lib" \
    "$ROCM_PATH/../_rocm_sdk_libraries/lib/hipblaslt" \
    "$ROCM_PATH/../_rocm_sdk_libraries/lib/rocblas"

for f in /usr/lib/x86_64-linux-gnu/libibverbs/*.so; do
    src="$f"
    dst="$INSTALL_PREFIX/lib/libibverbs/$(basename "$src")"
    cp -PT "$src" "$dst"

    if [ -L "$src" ]; then
        src="$(readlink -f "$src")"
        dst="$INSTALL_PREFIX/lib/$(basename "$src")"
        cp -T "$src" "$dst"
        patchelf --set-rpath \$'ORIGIN' "$dst"
    else
        patchelf --set-rpath \$'ORIGIN:'\$'ORIGIN/..' "$dst"
    fi
done

find "$INSTALL_PREFIX" -type f \
    -exec ldd {} + 2>/dev/null \
| sed -n 's/^[[:space:]]*\([^[:space:]]*\) => \([^()]*\).*/\1 => \2/p' \
| sed 's/[[:space:]]*$//' \
| grep -v "=> $INSTALL_PREFIX" \
| sort -u

# shellcheck source=/dev/null
. "$MY_DIR/pkginfo.txt"

tar caf "$MY_DIR/$NAME" -C "$INSTALL_PREFIX/.." llama.cpp

if [ -n "${MY_USER:-}" ]; then
    chown "$MY_USER:" "$MY_DIR/$NAME" "$MY_DIR/pkginfo.txt"
fi
