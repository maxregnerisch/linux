#!/bin/bash
set -ex
#export VERSION=$(cat debian/changelog | head -n 1 | sed "s/.*(//g" | sed "s/).*//g")
export MROS_VERSION=1.0
# Stage 1: build
docker build --build-arg VERSION=${VERSION} -t mros-build:${MROS_VERSION} .
# Stage 2: create container
docker create --name mros-build-${MROS_VERSION} mros-build:${MROS_VERSION}
# Stage 3: copy files
docker cp mros-build-${MROS_VERSION}:/build/linux-image-${VERSION}-mros-${MROS_VERSION}.deb .
docker cp mros-build-${MROS_VERSION}:/build/linux-headers-${VERSION}-mros-${MROS_VERSION}.deb .
# Stage 4: cleanup
docker rm mros-build-${MROS_VERSION}
docker rmi mros-build:${MROS_VERSION}
# Stage 5: rebrand files
mv linux-image-${VERSION}-mros-${MROS_VERSION}.deb linux-image-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb
mv linux-headers-${VERSION}-mros-${MROS_VERSION}.deb linux-headers-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb
# Stage 6: sign files
gpg --detach-sign linux-image-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb
gpg --detach-sign linux-headers-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb
# Stage 7: upload files
scp linux-image-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb*
scp linux-headers-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb*
# Stage 8: cleanup
rm linux-image-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb*
rm linux-headers-${VERSION}-mros-${MROS_VERSION}-generic_${MROS_VERSION}_amd64.deb*
