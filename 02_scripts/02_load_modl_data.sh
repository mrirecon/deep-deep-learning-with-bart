#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

mkdir -p $(dirname $DATA_PATH_MODL_BRAIN)
download https://zenodo.org/record/6481291/files/dataset.hdf5 $DATA_PATH_MODL_BRAIN