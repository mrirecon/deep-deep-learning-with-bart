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

cd $REPO/00_data/
download https://zenodo.org/record/6520889/files/example_data.zip example_data.zip
unzip -n example_data.zip

cd $REPO/Figure_07/
download https://zenodo.org/record/6520889/files/timing_logs.zip timing_logs.zip
unzip -n timing_logs.zip