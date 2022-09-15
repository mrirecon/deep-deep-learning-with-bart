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

source $REPO/00_data/02_dataset_description/03_knee_radial.sh
bart rss 8 $eval_col scl

MODEL_PATH=$REPO/12_varnet/20201117_164101_radial_tick/
(
    source $MODEL_PATH/00_config.sh    
    
    bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$eval_trj $eval_ksp $eval_col $MODEL_PATH/11_weights out1
    bart fmac out1 scl out

    bart measure --ssim out $eval_ref $OUT_PATH/measures/varnet_ssim
    bart measure --psnr out $eval_ref $OUT_PATH/measures/varnet_psnr
)

MODEL_PATH=$REPO/13_modl/20210129_200343_knee_radial_tick_more_cg_fl_init/
(
    source $MODEL_PATH/00_config.sh    
    
    bart reconet --network=modl --apply -I$ITERATIONS1  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$eval_trj $eval_ksp $eval_col $MODEL_PATH/10_weights_one out1
    bart fmac out1 scl out

    bart measure --ssim out $eval_ref $OUT_PATH/measures/modl1_ssim
    bart measure --psnr out $eval_ref $OUT_PATH/measures/modl1_psnr
)

MODEL_PATH=$REPO/13_modl/20210129_200343_knee_radial_tick_more_cg_fl_init/
(
    source $MODEL_PATH/00_config.sh    
    
    bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$eval_trj $eval_ksp $eval_col $MODEL_PATH/11_weights out1
    bart fmac out1 scl out

    bart measure --ssim out $eval_ref $OUT_PATH/measures/modl2_ssim
    bart measure --psnr out $eval_ref $OUT_PATH/measures/modl2_psnr
)


OUT_CG=""
OUT_L1=""
for i in $(seq 0 $(($(bart show -d 15 $eval_ref)-1)))
do
    bart slice 15 $i $eval_col col
    bart slice 15 $i $eval_ksp ksp

    bart pics -S ${BART_GPU=} -r0.1 -l2 -t$eval_trj ksp col out_cg_$i
    bart pics -S ${BART_GPU=} -i100 -e -r0.0006 -l1 -t$eval_trj ksp col out_l1_$i
    OUT_CG+=" out_cg_$i"
    OUT_L1+=" out_l1_$i"
done

bart join 15 $OUT_CG out1
bart fmac out1 scl out
bart measure --ssim out $eval_ref $OUT_PATH/measures/pics_cg_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/pics_cg_psnr

bart join 15 $OUT_L1 out1
bart fmac out1 scl out
bart measure --ssim out $eval_ref $OUT_PATH/measures/pics_l1_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/pics_l1_psnr
