#!/bin/sh

set -eu

sed -i '/^Suites:/s/ noble-backports\>//g' /etc/apt/sources.list.d/ubuntu.sources

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apt-utils

DEBIAN_FRONTEND=noninteractive apt-get -y install \
    dialog

printf 'Europe/Lisbon\n' > /etc/timezone

DEBIAN_FRONTEND=noninteractive apt-get -y install \
    tzdata

{
    printf 'locales locales/default_environment_locale select en_US.UTF-8\n'
    printf 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8, pt_PT.UTF-8 UTF-8\n'
} | debconf-set-selections

{
    printf 'LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_CTYPE=pt_PT.UTF-8\nLC_NUMERIC=pt_PT.UTF-8\nLC_TIME=pt_PT.UTF-8\nLC_COLLATE=pt_PT.UTF-8\nLC_MONETARY=pt_PT.UTF-8\n'
    printf 'LC_MESSAGES=en_US.UTF-8\nLC_PAPER=pt_PT.UTF-8\nLC_NAME=pt_PT.UTF-8\nLC_ADDRESS=pt_PT.UTF-8\nLC_TELEPHONE=pt_PT.UTF-8\nLC_MEASUREMENT=pt_PT.UTF-8\nLC_IDENTIFICATION=pt_PT.UTF-8\n'
} >/etc/default/locale

apt-get -y install \
    locales

{
    printf 'XKBLAYOUT="pt"\n'
    printf 'XKBMODEL="pc105"\n'
} >/etc/default/keyboard

DEBIAN_FRONTEND=noninteractive apt-get -y install \
    keyboard-configuration

{
    printf 'CHARMAP="UTF-8"\n'
    printf 'CODESET="guess"\n'
} >/etc/default/console-setup

DEBIAN_FRONTEND=noninteractive apt-get -y install \
    console-setup

apt-mark showauto | xargs apt-mark manual

apt-get -y install \
    bash-completion \
    command-not-found \
    nano \
    patch \
    ubuntu-minimal

apt-get update
apt-get -y dist-upgrade

apt-get clean
find /var/lib/apt/lists -type f ! -name lock -print0 | xargs -0I% rm "%"

# diff -u3 bash.bashrc.bak bash.bashrc | sed '1,2d' | base64 -w0
printf '%s' \
    'QEAgLTMyLDEzICszMiwxMyBAQAogI2VzYWMKIAogIyBlbmFibGUgYmFzaCBjb21wbGV0aW9uIGluIGludGVyYWN0aXZlIHNoZWxscwotI2lmICEgc2hvcHQgLW9xIHBvc2l4OyB0aGVuCi0jICBpZiBbIC1mIC91c3Ivc2hhcmUvYmFzaC1jb' \
    '21wbGV0aW9uL2Jhc2hfY29tcGxldGlvbiBdOyB0aGVuCi0jICAgIC4gL3Vzci9zaGFyZS9iYXNoLWNvbXBsZXRpb24vYmFzaF9jb21wbGV0aW9uCi0jICBlbGlmIFsgLWYgL2V0Yy9iYXNoX2NvbXBsZXRpb24gXTsgdGhlbgotIyAgICAuIC' \
    '9ldGMvYmFzaF9jb21wbGV0aW9uCi0jICBmaQotI2ZpCitpZiAhIHNob3B0IC1vcSBwb3NpeDsgdGhlbgorICBpZiBbIC1mIC91c3Ivc2hhcmUvYmFzaC1jb21wbGV0aW9uL2Jhc2hfY29tcGxldGlvbiBdOyB0aGVuCisgICAgLiAvdXNyL3N' \
    'oYXJlL2Jhc2gtY29tcGxldGlvbi9iYXNoX2NvbXBsZXRpb24KKyAgZWxpZiBbIC1mIC9ldGMvYmFzaF9jb21wbGV0aW9uIF07IHRoZW4KKyAgICAuIC9ldGMvYmFzaF9jb21wbGV0aW9uCisgIGZpCitmaQogCiAjIHN1ZG8gaGludAogaWYg' \
    'WyAhIC1lICIkSE9NRS8uc3Vkb19hc19hZG1pbl9zdWNjZXNzZnVsIiBdICYmIFsgISAtZSAiJEhPTUUvLmh1c2hsb2dpbiIgXSA7IHRoZW4K' \
| base64 -d \
| patch /etc/bash.bashrc

printf '%s' \
    'QEAgLTEwOCwxMCArMTA4LDEwIEBACiAjIGVuYWJsZSBwcm9ncmFtbWFibGUgY29tcGxldGlvbiBmZWF0dXJlcyAoeW91IGRvbid0IG5lZWQgdG8gZW5hYmxlCiAjIHRoaXMsIGlmIGl0J3MgYWxyZWFkeSBlbmFibGVkIGluIC9ldGMvYmFza' \
    'C5iYXNocmMgYW5kIC9ldGMvcHJvZmlsZQogIyBzb3VyY2VzIC9ldGMvYmFzaC5iYXNocmMpLgotaWYgISBzaG9wdCAtb3EgcG9zaXg7IHRoZW4KLSAgaWYgWyAtZiAvdXNyL3NoYXJlL2Jhc2gtY29tcGxldGlvbi9iYXNoX2NvbXBsZXRpb2' \
    '4gXTsgdGhlbgotICAgIC4gL3Vzci9zaGFyZS9iYXNoLWNvbXBsZXRpb24vYmFzaF9jb21wbGV0aW9uCi0gIGVsaWYgWyAtZiAvZXRjL2Jhc2hfY29tcGxldGlvbiBdOyB0aGVuCi0gICAgLiAvZXRjL2Jhc2hfY29tcGxldGlvbgotICBmaQo' \
    'tZmkKKyNpZiAhIHNob3B0IC1vcSBwb3NpeDsgdGhlbgorIyAgaWYgWyAtZiAvdXNyL3NoYXJlL2Jhc2gtY29tcGxldGlvbi9iYXNoX2NvbXBsZXRpb24gXTsgdGhlbgorIyAgICAuIC91c3Ivc2hhcmUvYmFzaC1jb21wbGV0aW9uL2Jhc2hf' \
    'Y29tcGxldGlvbgorIyAgZWxpZiBbIC1mIC9ldGMvYmFzaF9jb21wbGV0aW9uIF07IHRoZW4KKyMgICAgLiAvZXRjL2Jhc2hfY29tcGxldGlvbgorIyAgZmkKKyNmaQo=' \
| base64 -d \
| patch /etc/skel/.bashrc

printf '%%sudo ALL=(ALL:ALL) NOPASSWD: ALL\n' >/etc/sudoers.d/99-nopasswd
chmod 0440 /etc/sudoers.d/99-nopasswd

userdel -r ubuntu

groupadd -g "$MY_GID" "$MY_USER"

_gaudio="$(getent group "$AUDIO_GID" | cut -d: -f1)"
if [ -z "$_gaudio" ]; then _gaudio=host_audio; groupadd -g "$AUDIO_GID" "$_gaudio"; fi

_gdocker="$(getent group "$DOCKER_GID" | cut -d: -f1)"
if [ -z "$_gdocker" ]; then _gdocker=host_docker; groupadd -g "$DOCKER_GID" "$_gdocker"; fi

_grender="$(getent group "$RENDER_GID" | cut -d: -f1)"
if [ -z "$_grender" ]; then _grender=host_render; groupadd -g "$RENDER_GID" "$_grender"; fi

_gvideo="$(getent group "$VIDEO_GID" | cut -d: -f1)"
if [ -z "$_gvideo" ]; then _gvideo=host_video; groupadd -g "$VIDEO_GID" "$_gvideo"; fi

useradd -g "$MY_GID" -G "sudo,$_gaudio,$_gdocker,$_grender,$_gvideo" -m -s /usr/bin/bash -u "$MY_UID" "$MY_USER"
