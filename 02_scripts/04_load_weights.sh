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

cd $REPO/12_varnet
download https://zenodo.org/record/6520889/files/varnet_weights.zip varnet_weights.zip
unzip -n varnet_weights.zip

cd $REPO/13_modl
download https://zenodo.org/record/6520889/files/modl_weights.zip modl_weights.zip
unzip -n modl_weights.zip