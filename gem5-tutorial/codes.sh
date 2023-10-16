#!/bin/sh

gem5_tut_directory=$(pwd)

cd ../buildroot
make BR2_EXTERNAL=$gem5_tut_directory/buildroot gem5_defconfig && make -j$(nproc)

cp output/images/rootfs.ext2 $current_directory/resources
cp output/images/vmlinux $current_directory/resources

cd ../gem5-tutorial/
git clone https://github.com/gem5/gem5.git
cd gem5
scons build/ARM/gem5.fast -j$(nproc)

export GIT_ROOT=$current_directory
cd  ../run-scripts
./run-script.sh --take-checkpoint --script gem5-script.sh
