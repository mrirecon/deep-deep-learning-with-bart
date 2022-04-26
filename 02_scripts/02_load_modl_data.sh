#!/bin/bash

set -eu

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