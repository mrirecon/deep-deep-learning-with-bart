#!/bin/bash
set -eu

OUT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cd $OUT_PATH

mkdir -p $OUT_PATH/measures/

TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$TDIR"' EXIT

source $REPO/00_data/02_dataset_description/04_knee_alias_1.sh
MODEL_PATH=$REPO/12_varnet/20201117_164101_default_alias_1map_mse/
(
    source $MODEL_PATH/00_config.sh
    bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights $TDIR/out
    bart fmac -s$(bart bitmask 4) $TDIR/out $eval_col $TDIR/cim

    bart measure --ssim $TDIR/cim $eval_ref $OUT_PATH/measures/vn_1map_ssim
    bart measure --psnr $TDIR/cim $eval_ref $OUT_PATH/measures/vn_1map_psnr
)

source $REPO/00_data/02_dataset_description/05_knee_alias_2.sh
MODEL_PATH=$REPO/12_varnet/20201117_164101_default_alias_2map_mse/
(
    source $MODEL_PATH/00_config.sh
    bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights $TDIR/out
    bart fmac -s$(bart bitmask 4) $TDIR/out $eval_col $TDIR/cim

    bart measure --ssim $TDIR/cim $eval_ref $OUT_PATH/measures/vn_2map_ssim
    bart measure --psnr $TDIR/cim $eval_ref $OUT_PATH/measures/vn_2map_psnr
)

source $REPO/00_data/02_dataset_description/04_knee_alias_1.sh
MODEL_PATH=$REPO/13_modl/20201118_183735_knee_default_alias_1map_mse
(
    source $MODEL_PATH/00_config.sh
    bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights $TDIR/out
    bart fmac -s$(bart bitmask 4) $TDIR/out $eval_col $TDIR/cim

    bart measure --ssim $TDIR/cim $eval_ref $OUT_PATH/measures/modl_1map_ssim
    bart measure --psnr $TDIR/cim $eval_ref $OUT_PATH/measures/modl_1map_psnr
)

source $REPO/00_data/02_dataset_description/05_knee_alias_2.sh
MODEL_PATH=$REPO/13_modl/20201118_183735_knee_default_alias_2map_mse
(
    source $MODEL_PATH/00_config.sh
    bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$eval_pat $eval_ksp $eval_col $MODEL_PATH/11_weights $TDIR/out
    bart fmac -s$(bart bitmask 4) $TDIR/out $eval_col $TDIR/cim

    bart measure --ssim $TDIR/cim $eval_ref $OUT_PATH/measures/modl_2map_ssim
    bart measure --psnr $TDIR/cim $eval_ref $OUT_PATH/measures/modl_2map_psnr
)