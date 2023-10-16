#!/bin/sh

export GIT_ROOT=$(pwd)
cd  run-scripts
./run-script.sh --take-checkpoint --script gem5-script.sh
