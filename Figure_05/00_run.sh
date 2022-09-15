#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

#VarNet Reconstruction
DATA_PATH=$REPO/00_data/01_example_data/02_vn_data_alias/

TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$TDIR"' EXIT

PAT=$DATA_PATH/mask

for i in 1 2
do

    KSP=$DATA_PATH/ksp${i}

    COL=$DATA_PATH/col${i}_1map
    MODEL_PATH=$REPO/12_varnet/20201117_164101_default_alias_1map_mse/
    (
        source $MODEL_PATH/00_config.sh
        bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights $TDIR/out
        bart fmac -s$(bart bitmask 4) $TDIR/out $COL $TDIR/cim
        bart rss $(bart bitmask 3) $TDIR/cim reco_vn_${i}_1map
    )

    COL=$DATA_PATH/col${i}_2map
    MODEL_PATH=$REPO/12_varnet/20201117_164101_default_alias_2map_mse/
    (
        source $MODEL_PATH/00_config.sh
        bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights $TDIR/out
        bart fmac -s$(bart bitmask 4) $TDIR/out $COL $TDIR/cim
        bart rss $(bart bitmask 3) $TDIR/cim reco_vn_${i}_2map
    )

    COL=$DATA_PATH/col${i}_1map
    MODEL_PATH=$REPO/13_modl/20201118_183735_knee_default_alias_1map_mse
    (
        source $MODEL_PATH/00_config.sh
        bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights $TDIR/out
        bart fmac -s$(bart bitmask 4) $TDIR/out $COL $TDIR/cim
        bart rss $(bart bitmask 3) $TDIR/cim reco_modl_${i}_1map
    )

    COL=$DATA_PATH/col${i}_2map
    MODEL_PATH=$REPO/13_modl/20201118_183735_knee_default_alias_2map_mse
    (
        source $MODEL_PATH/00_config.sh
        bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --pattern=$PAT $KSP $COL $MODEL_PATH/11_weights $TDIR/out
        bart fmac -s$(bart bitmask 4) $TDIR/out $COL $TDIR/cim
        bart rss $(bart bitmask 3) $TDIR/cim reco_modl_${i}_2map
    )
done