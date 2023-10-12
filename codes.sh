#!/bin/sh

cd ../buildroot
make BR2_EXTERNAL=/home/h255t794/gem-tutorial/gem5-tutorial/buildroot gem5_defconfig && make -j 4
cp output/images/rootfs.ext2 /home/h255t794/gem-tutorial/gem5-tutorial/resources
cp output/images/vmlinux /home/h255t794/gem-tutorial/gem5-tutorial/resources

cd ../gem5-tutorial/gem5
scons build/ARM/gem5.fast -j$(nproc)

export GIT_ROOT=/home/h255t794/gem-tutorial/gem5-tutorial
cd  ../run-scripts
./run-script.sh --take-checkpoint 

