#!/bin/bash

PACKAGE_ARCH=$1
OS=$2
DISTRO=$3

# There are no distro specific options in this because this package only works on a raspberry pi, the jetson
# veye library is entirely separate

PACKAGE_NAME=veye-raspberrypi

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

rm -rf ${TMPDIR}/*

mkdir -p ${TMPDIR}/usr/local/share/veye-raspberrypi || exit 1

cp -a veye_raspcam/bin/* ${TMPDIR}/usr/local/share/veye-raspberrypi/ || exit 1
cp -a i2c_cmd/bin/* ${TMPDIR}/usr/local/share/veye-raspberrypi/ || exit 1
chmod +x ${TMPDIR}/usr/local/share/veye-raspberrypi/* || exit 1

cd /home/runner/work/veye_raspberrypi/veye_raspberrypi
VER2=$(git rev-parse --short HEAD)
echo ${VER2}
VERSION="2.2.1-evo-$(date '+%m%d%H%M')-${VER2}"
cd /data/
rm ${PACKAGE_NAME}_${VERSION}_${PACKAGE_ARCH}.deb > /dev/null 2>&1

sudo fpm -a ${PACKAGE_ARCH} -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION} -C ${TMPDIR} \
  -p /home/runner/work/veye_raspberrypi/veye_raspberrypi/${PACKAGE_NAME}_VERSION_ARCH.deb || exit 1

#
# Only push to cloudsmith for tags. If you don't want something to be pushed to the repo, 
# don't create a tag. You can build packages and test them locally without tagging.
#
cd /home/runner/work/veye_raspberrypi/veye_raspberrypi
