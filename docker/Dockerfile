ARG BASE_IMAGE=scratch

FROM ${BASE_IMAGE}

ARG AUDIO_GID=
ARG DOCKER_GID=
ARG MY_GID=
ARG MY_UID=
ARG MY_USER=
ARG RENDER_GID=
ARG VIDEO_GID=

RUN --mount=type=bind,source=setup.sh,target=/setup.sh,readonly \
    AUDIO_GID="${AUDIO_GID}" \
    DOCKER_GID="${DOCKER_GID}" \
    MY_GID="${MY_GID}" \
    MY_UID="${MY_UID}" \
    MY_USER="${MY_USER}" \
    RENDER_GID="${RENDER_GID}" \
    VIDEO_GID="${VIDEO_GID}" \
        /bin/sh /setup.sh

ENV MY_USER=${MY_USER}

USER ${MY_USER}
