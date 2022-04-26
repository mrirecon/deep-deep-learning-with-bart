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

mkdir -p $DATA_PATH_VN_KNEE
for pat in $(seq 20)
do
	download https://zenodo.org/record/6482961/files/col_${pat}.hdr $DATA_PATH_VN_KNEE/col_${pat}.hdr
	download https://zenodo.org/record/6482961/files/col_${pat}.cfl $DATA_PATH_VN_KNEE/col_${pat}.cfl
	download https://zenodo.org/record/6482961/files/ksp_${pat}.hdr $DATA_PATH_VN_KNEE/ksp_${pat}.hdr
	download https://zenodo.org/record/6482961/files/ksp_${pat}.cfl $DATA_PATH_VN_KNEE/ksp_${pat}.cfl
done