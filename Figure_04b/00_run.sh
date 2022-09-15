#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

TMP=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$TMP"' EXIT



DATA_PATH=$REPO/00_data/01_example_data/03_modl_data/
KSP=$DATA_PATH/tst_kspace
COL=$DATA_PATH/tst_coil
REF=$DATA_PATH/tst_ref
PAT=$DATA_PATH/tst_mask

# Adjoint Reco
bart fft -u -i 3 $KSP $TMP/tmp_ci
bart fmac -C -s8 $TMP/tmp_ci $DATA_PATH/tst_coil reco_adjoint

# PICS Reco
bart pics ${BART_GPU=} -S -r 0.01 -l1 -p$PAT $KSP $COL reco_pics

# Reconstruction MoDL
MODEL_PATH=$REPO/13_modl/20201127_191939_brain_10_iter
source $MODEL_PATH/00_config.sh
bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights reco_bart
