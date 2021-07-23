#!/bin/bash

PLATFORM=$1
DISTRO=$2
BUILD_TYPE=$3

if [[ "${PLATFORM}" == "pi" ]]; then
    OS="raspbian"
    ARCH="arm"
    PACKAGE_ARCH="armhf"
fi

if [ "${BUILD_TYPE}" == "docker" ]; then
    cat << EOF > /etc/resolv.conf
options rotate
options timeout:1
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
fi

PACKAGE_NAME=veye-raspberrypi

TMPDIR=/tmp/${PACKAGE_NAME}-installdir

rm -rf ${TMPDIR}/*

mkdir -p ${TMPDIR}/usr/local/bin || exit 1
mkdir -p ${TMPDIR}/usr/local/share/veye-raspberrypi || exit 1

pushd veye_raspcam/source
chmod +x buildme || exit 1
./buildme || exit 1
cp veye_* ${TMPDIR}/usr/local/bin/ || exit 1
popd

chmod +x ${TMPDIR}/usr/local/bin/* || exit 1

cp -a i2c_cmd/bin/* ${TMPDIR}/usr/local/share/veye-raspberrypi/ || exit 1
chmod +x ${TMPDIR}/usr/local/share/veye-raspberrypi/* || exit 1

VERSION=$(git describe)

rm ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb > /dev/null 2>&1

fpm -a ${PACKAGE_ARCH} -s dir -t deb -n ${PACKAGE_NAME} -v ${VERSION//v} -C ${TMPDIR} \
  -p ${PACKAGE_NAME}_VERSION_ARCH.deb || exit 1

#
# Only push to cloudsmith for tags. If you don't want something to be pushed to the repo, 
# don't create a tag. You can build packages and test them locally without tagging.
#
git describe --exact-match HEAD > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Pushing package to OpenHD repository"
    cloudsmith push deb openhd/openhd-2-0/${OS}/${DISTRO} ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb || exit 1
else
    echo "Pushing package to OpenHD testing repository"
    cloudsmith push deb openhd/openhd-2-0-testing/${OS}/${DISTRO} ${PACKAGE_NAME}_${VERSION//v}_${PACKAGE_ARCH}.deb || exit 1
fi
