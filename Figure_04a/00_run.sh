#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

KSP=$REPO/00_data/01_example_data/01_vn_data/ksp
COL=$REPO/00_data/01_example_data/01_vn_data/col
REF=$REPO/00_data/01_example_data/01_vn_data/ref
PAT=$REPO/00_data/01_example_data/01_vn_data/pat

TMP=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$TMP"' EXIT

#remove frequency oversampling
bart fft -u -i 1 $KSP $TMP/cim_os
bart resize -c 0 320 $TMP/cim_os $TMP/cim
bart fft -u  1 $TMP/cim $TMP/ksp
bart resize -c 0 320 $PAT $TMP/pat

#pics reco
bart pics -S ${BART_GPU=} -r 0.0025 -l1 -p$TMP/pat $TMP/ksp $COL reco_pics

#adjoint reco
bart fft -u -i 3 $KSP $TMP/tmp_ci
bart resize -c 0 320 $TMP/tmp_ci $TMP/tmp_ci_s
bart fmac -C -s8 $TMP/tmp_ci_s $COL reco_adjoint

MODEL_PATH=$REPO/12_varnet/20201117_164101_default/

source $MODEL_PATH/00_config.sh

#BART weights
bart reconet --network=varnet --apply -I$ITERATIONS ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights reco_bart

#TensorFlow weights
WGH=$REPO/00_data/01_example_data/mri_vn_2022-01-15--00-39-01/checkpoints_bart/wgh-900
bart reconet --network=varnet --apply -I$ITERATIONS ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $WGH reco_tf