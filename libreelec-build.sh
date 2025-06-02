#!/bin/bash
#
# This script runs a Docker container to build LibreELEC images.
# Usage: ./run.sh [rpi5|x86_64] {command to run within the libreelec container}
#
#   ./libreelec-build.sh rpi5 scripts/build mdadm
#
#   ./libreelec-build.sh rpi5 make image
#
set -xeuo pipefail

case ${1:-rpi5} in
  (rpi5) run_args="-e PROJECT=RPi -e ARCH=aarch64 -e DEVICE=RPi5" ; shift 1 ;;
  (x86_64) run_args="PROJECT=Generic -e DEVICE=Generic -e ARCH=x86_64 " ; shift 1 ;;
  (*)
    run_args="-e PROJECT=RPi -e ARCH=aarch64 -e DEVICE=RPi5"
    echo "WARNING: unknown arch/dev. Using Docker arguments: '${run_args}'" 1>&2
    ;;
esac

# https://wiki.libreelec.tv/development/build-docker#advanced
docker run \
  -it --rm \
  --log-driver none \
  -v $(pwd):/build -w /build \
  `# setting these the same disables swapping` \
  `#--memory "12g" --memory-swap "12g"` \
  `# uses all cpus, but will reserve cycles on each` \
  --cpus "3.5" \
  `# limit to certain processors` \
  `# --cpuset-cpus "0-3"` \
  ${run_args} \
  -e MTPROGRESS=yes \
  -e THREADCOUNT=100% \
  -e BUILDER_NAME=aredub \
  libreelec $@
