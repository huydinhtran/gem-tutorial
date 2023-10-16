#!/bin/sh

git clone https://github.com/buildroot/buildroot.git
cp -r buildroot/ gem5-tutorial/buildroot/
cd gem5-tutorial
mkdir resources ckpts rundir guest-scripts
cd resources
wget http://dist.gem5.org/dist/v22-0/arm/aarch-system-20220707.tar.bz2
tar -xf aarch-system-20220707.tar.bz2
rm aarch-system-20220707.tar.bz2
cd ../
./codes.sh
