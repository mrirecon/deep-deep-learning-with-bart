#!/bin/bash
set -eu

OUT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd $OUT_PATH

mkdir -p $OUT_PATH/measures/

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

MODEL_PATH=$REPO/13_modl/20201127_191939_brain_10_iter


source $MODEL_PATH/00_config.sh
weights=$MODEL_PATH/11_weights
bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights out1
bart rss 8 $eval_col scl
bart fmac out1 scl out
    
bart measure --ssim out $eval_ref $OUT_PATH/measures/bart_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/bart_psnr

OUT=""
for i in $(seq 0 $(($(bart show -d 15 $eval_ref)-1)))
do
    bart slice 15 $i $eval_pat pat
    bart slice 15 $i $eval_col col
    bart slice 15 $i $eval_ksp ksp

    bart pics -S ${BART_GPU=} -r 0.01 -l1 -ppat ksp col out_$i
    OUT+=" out_$i"
done
bart join 15 $OUT out1
bart fmac out1 scl out

bart measure --ssim out $eval_ref $OUT_PATH/measures/pics_ssim
bart measure --psnr out $eval_ref $OUT_PATH/measures/pics_psnr

# The original MoDL reconstruction is not part of the repository
TF_RECO=$REPO/00_data/01_example_data/03_modl_data/evl_out_tf

if [ -f "${TF_RECO}.hdr" ]; then

    bart fmac $TF_RECO scl out
    bart measure --ssim out $eval_ref $OUT_PATH/measures/tf_ssim
    bart measure --psnr out $eval_ref $OUT_PATH/measures/tf_psnr
fi
