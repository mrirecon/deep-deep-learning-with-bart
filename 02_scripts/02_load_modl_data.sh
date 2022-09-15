#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

download()
(
	URL=$1
	DST=$2

	if [ ! -f "$DST" ]; then
		TMPFILE=$(mktemp)
   		wget -O $TMPFILE $URL
		mv $TMPFILE $DST
	fi
)

mkdir -p $(dirname $DATA_PATH_MODL_BRAIN)
download https://zenodo.org/record/6481291/files/dataset.hdf5 $DATA_PATH_MODL_BRAIN