#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

OUT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd $OUT_PATH

mkdir -p $OUT_PATH/measures/

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

MODEL_PATH=$REPO/12_varnet/20201117_164101_default/

source $MODEL_PATH/00_config.sh

bart rss 8 $eval_col scl

bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights out1
bart fmac out1 scl out

bart measure --ssim out $eval_ref $OUT_PATH/measures/bart_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/bart_psnr

WGH=$REPO/00_data/01_example_data/mri_vn_2022-01-15--00-39-01/checkpoints_bart/wgh-900
bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $WGH out1
bart fmac out1 scl out

bart measure --ssim out $eval_ref $OUT_PATH/measures/tf_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/tf_psnr

PICS_ADD_OPTS=""
if bart pics --interface 2>&1 | grep -q fista_last >/dev/null 2>&1 ; then
	PICS_ADD_OPTS="--fista_last"
fi

OUT=""
for i in $(seq 0 $(($(bart show -d 15 $eval_ref)-1)))
do
    bart slice 15 0 $eval_pat pat1
    bart slice 15 $i $eval_col col
    bart slice 15 $i $eval_ksp ksp

    bart fft -u -i 1 ksp cim_os
    bart resize -c 0 320 cim_os cim
    bart fft -u  1 cim ksp1

    bart resize -c 0 320 pat1 pat
    bart fmac ksp1 pat ksp

    bart pics -S ${BART_GPU=} -r 0.0025 -l1 $PICS_ADD_OPTS -ppat ksp col out_$i
    OUT+=" out_$i"
done
bart join 15 $OUT out1
bart fmac out1 scl out

bart measure --ssim out $eval_ref $OUT_PATH/measures/pics_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/pics_psnr
