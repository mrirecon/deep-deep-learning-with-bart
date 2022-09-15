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

mkdir -p $DATA_PATH_VN_KNEE
for pat in $(seq 20)
do
	download https://zenodo.org/record/6482961/files/col_${pat}.hdr $DATA_PATH_VN_KNEE/col_${pat}.hdr
	download https://zenodo.org/record/6482961/files/col_${pat}.cfl $DATA_PATH_VN_KNEE/col_${pat}.cfl
	download https://zenodo.org/record/6482961/files/ksp_${pat}.hdr $DATA_PATH_VN_KNEE/ksp_${pat}.hdr
	download https://zenodo.org/record/6482961/files/ksp_${pat}.cfl $DATA_PATH_VN_KNEE/ksp_${pat}.cfl
done