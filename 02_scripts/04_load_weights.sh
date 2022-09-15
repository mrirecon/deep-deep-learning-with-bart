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

cd $REPO/12_varnet
download https://zenodo.org/record/7002209/files/varnet_weights.zip varnet_weights.zip
unzip -n varnet_weights.zip

cd $REPO/13_modl
download https://zenodo.org/record/7002209/files/modl_weights.zip modl_weights.zip
unzip -n modl_weights.zip