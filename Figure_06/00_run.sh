#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

export OMP_NUM_THREADS=1 #More deterministic due to gridding

DATA_PATH=$REPO/00_data/01_example_data/01_vn_data/
KSP=$DATA_PATH/ksp_rad
COL=$DATA_PATH/col
REF=$DATA_PATH/ref
TRJ=$DATA_PATH/trj

#VarNet Reconstruction
MODEL_PATH=$REPO/12_varnet/20201117_164101_radial_tick/
source $MODEL_PATH/00_config.sh
bart reconet --network=varnet --apply -I$ITERATIONS  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$TRJ $KSP $COL $MODEL_PATH/11_weights reco_varnet

# MoDL Reconstruction
MODEL_PATH=$REPO/13_modl/20210129_200343_knee_radial_tick_more_cg_fl_init/
source $MODEL_PATH/00_config.sh
bart reconet --network=modl --apply -I$ITERATIONS1  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$TRJ $KSP $COL $MODEL_PATH/10_weights_one reco_modl_one
bart reconet --network=modl --apply -I$ITERATIONS2  ${BART_GPU=} ${NORMALIZE=} $network_opts --trajectory=$TRJ $KSP $COL $MODEL_PATH/11_weights reco_modl

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT

PICS_ADD_OPTS=""
if bart pics --interface 2>&1 | grep -q fista_last >/dev/null 2>&1 ; then
	PICS_ADD_OPTS="--fista_last"
fi

# PICS Reconstruction
bart ones 3 1 $(bart show -d 1 $KSP) $(bart show -d 2 $KSP) $WORKDIR/pat
bart pics -S -i100 -e -r0.0006 -l1 $PICS_ADD_OPTS -t$TRJ ${BART_GPU=} -p$WORKDIR/pat $KSP $COL reco_pics_l1
bart pics -S -r0.1 -l2 -t$TRJ ${BART_GPU=} -p$WORKDIR/pat $KSP $COL reco_pics

#Weights for density compensation
FRE=$(bart show -d 1 $KSP)
NOR=$(echo "2 / ($FRE - 1)" | bc -l)
bart scale $NOR $TRJ $WORKDIR/trj_s
bart rss 1 $WORKDIR/trj_s $WORKDIR/trj_sa
bart spow 0.5 $WORKDIR/trj_sa $WORKDIR/wgh
bart fmac $WORKDIR/wgh $KSP $WORKDIR/tmp_ksp

bart nufft -a -d320:368:1 $TRJ $WORKDIR/tmp_ksp $WORKDIR/cim
bart fmac -C -s8 $WORKDIR/cim $COL reco_adjoint
