#!/bin/bash
#
# This script builds the LibreELEC build image using Docker.
# Usage: ./build-librelec-build-image.sh [codename]
#
# https://wiki.libreelec.tv/development/build-docker#build-container
#
set -euo pipefail

codename=${1:-focal}

case ${codename} in
  (focal) dockerfile=tools/docker/focal/Dockerfile
  # apply patches to make the image like in CI
  sed -i -e "/^USER docker/i RUN ln -s /usr/bin/gcc-10 /usr/bin/cc" ${dockerfile}
  ;;
  (jammy|noble|bookwork) dockerfile=tools/docker/${codename}/Dockerfile ;;
  (*)
    echo "Unknown codename '${codename}'" >&2
    exit 1
    ;;
esac

# per tools/docker/README.md
docker build --pull -t libreelec ${dockerfile}
