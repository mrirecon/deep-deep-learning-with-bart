#!/bin/bash

set -eu

cd $DATA_ARCHIVE/03_modl_data/

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