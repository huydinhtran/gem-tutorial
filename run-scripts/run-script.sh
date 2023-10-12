#!/bin/bash

CACHE_CONFIG="--caches --l3cache --l2cache --num-l2caches 8 --l1i_size=32kB --l1d_size=32kB --l1d_assoc=8 --l2_size=1MB --l2_assoc=16 --l3_size=8MB"

function usage {
  echo "  --script <script> : guest script to run"
  echo "  --take-checkpoint : take checkpoint after running"
  echo "  -h --help : print this message"
  exit 1
}

function setup_dirs {
  mkdir -p "$CKPT_DIR"
  mkdir -p "$RUNDIR"
}

function run_simulation {
  "$GEM5_DIR/build/ARM/gem5.$GEM5TYPE" $DEBUG_FLAGS --outdir="$RUNDIR" \
  "$GEM5_DIR"/configs/deprecated/example/fs.py --cpu-type=$CPUTYPE --cpu-clock=2GHz\
  --bootloader="$RESOURCES/boot.arm64" --root=/dev/sda  --kernel="$RESOURCES/$SCRIPT_NAME/vmlinux" --disk="$RESOURCES/$SCRIPT_NAME/rootfs.ext2" \
  --num-cpus=1 --mem-type=DDR4_2400_16x4 --mem-size=16192MB --script="$GUEST_SCRIPT_DIR/$GUEST_SCRIPT" \
  --checkpoint-dir="$CKPT_DIR" $CONFIGARGS
}

if [[ -z "${GIT_ROOT}" ]]; then
  echo "Please export env var GIT_ROOT to point to the root of the this repo"
  exit 1
fi


GEM5_DIR=${GIT_ROOT}/gem5
RESOURCES=${GIT_ROOT}/resources
GUEST_SCRIPT_DIR=${GIT_ROOT}/guest-scripts


# parse command line arguments
TEMP=$(getopt -o 'h' --long take-checkpoint,script:,help -n 'dpdk-loadgen' -- "$@")

# check for parsing errors
if [ $? != 0 ]; then
  echo "Error: unable to parse command line arguments" >&2
  exit 1
fi

eval set -- "$TEMP"

while true; do
  case "$1" in

  --take-checkpoint)
    checkpoint=1
    shift 1
    ;;
  --script)
    GUEST_SCRIPT="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  --)
    shift
    break
    ;;
  *) break ;;
  esac
done

CKPT_DIR=${GIT_ROOT}/ckpts/$GUEST_SCRIPT



if [[ -n "$checkpoint" ]]; then
  RUNDIR=${GIT_ROOT}/rundir/$GUEST_SCRIPT-"ckp"
  setup_dirs

  GEM5TYPE="fast"
  CPUTYPE="AtomicSimpleCPU"
  CONFIGARGS="--max-checkpoints 4"
  run_simulation | tee $RUNDIR/simout
  exit 0

  RUNDIR=${GIT_ROOT}/rundir/$GUEST_SCRIPT-BW-$RATE$CACHE_CLEANER-largerGap


  setup_dirs
  CPUTYPE="TimingSimpleCPU" # DerivO3CPU, TimingSimpleCPU, AtomicSimpleCPU
  GEM5TYPE="opt"
  DEBUG_FLAGS="--debug-flags="
  CONFIGARGS="$CACHE_CONFIG -r 2 --rel-max-tick=300000000000"
  run_simulation | tee $RUNDIR/simout
  exit
fi