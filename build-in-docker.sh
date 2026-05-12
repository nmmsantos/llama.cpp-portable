#!/bin/sh

set -eu

ME="$(readlink -f "$0")"
MY_DIR="$(dirname "$ME")"

BUILDER_CONTAINER="llama-cpp-portable-builder"
BUILDER_IMAGE="$BUILDER_CONTAINER:local"

docker build \
    --build-arg "AUDIO_GID=$(getent group audio | cut -d: -f3)" \
    --build-arg "BASE_IMAGE=ubuntu:24.04" \
    --build-arg "DOCKER_GID=$(getent group docker | cut -d: -f3)" \
    --build-arg "MY_GID=$(stat -c '%g' "$ME")" \
    --build-arg "MY_UID=$(stat -c '%u' "$ME")" \
    --build-arg "MY_USER=$(getent passwd "$(stat -c '%u' "$ME")" | cut -d: -f1)" \
    --build-arg "RENDER_GID=$(getent group render | cut -d: -f3)" \
    --build-arg "VIDEO_GID=$(getent group video | cut -d: -f3)" \
    --network host \
    --progress plain \
    -t "$BUILDER_IMAGE" \
    "$MY_DIR/docker"

if ! docker container inspect "$BUILDER_CONTAINER" >/dev/null 2>&1; then
    docker run \
        --device=/dev/dri \
        --device=/dev/kfd \
        --entrypoint /bin/sh \
        --gpus all \
        --name "$BUILDER_CONTAINER" \
        --network host \
        --rm \
        -d \
        -v "$MY_DIR:/work" \
        -w /work \
        "$BUILDER_IMAGE" \
        -c "while :; do sleep 1; done" \
        >/dev/null
fi

docker exec -u root "$BUILDER_CONTAINER" /work/00-build-dependencies.sh
docker exec -u root "$BUILDER_CONTAINER" /work/01-build-vulkan.sh
docker exec -u root "$BUILDER_CONTAINER" /work/02-build-rocm.sh
docker exec -u root "$BUILDER_CONTAINER" /work/03-build-cuda.sh
docker exec -u root "$BUILDER_CONTAINER" /work/04-finalize.sh
