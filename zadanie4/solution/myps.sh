#!/bin/sh
cp -rf usr /
cd /usr/src/lib/libc
make
make install
cd /usr/src/releasetools
make hdboot
