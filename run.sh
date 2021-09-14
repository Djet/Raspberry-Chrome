#!/bin/bash
##docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx build --platform linux/arm64 -f Dockerfile --load -t test:$1 .
docker export -o initramfs.tar $(docker create test:$1)
mkdir target && tar -xf initramfs.tar -C target/
rm -rf dev/*
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | lz4 -l -c > initrd.img

export SDCARD_MB=300

mv initrd.img sdcard/
truncate -s ${SDCARD_MB}M sdcard.img
mpartition -I -c -b 32 -s 32 -h 64 -t ${SDCARD_MB} -a "z:"
mformat -v "piPXE" "z:"
mcopy -s sdcard/* "z:"

rm -rf target initramfs.cpio  initramfs.tar  initrd.img
