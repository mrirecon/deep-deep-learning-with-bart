#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

./12_convert_modl_data.py

cd $DATA_DIR/03_modl_data/

for d in eval/ valid/ train/
do
(
    cd $d

    TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT

    bart fmac ref col $TDIR/cim
    bart fft -u 7 $TDIR/cim $TDIR/ksp

    bart noise -n0.0001 -s123 $TDIR/ksp $TDIR/ksp2
    bart fmac $TDIR/ksp2 pat ksp
)
done