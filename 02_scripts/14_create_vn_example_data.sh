#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

#Slice Example Reconstruction Data

cd $DATA_DIR/02_vn_data/coronal_pd_fs

EP=$REPO/00_data/01_example_data/01_vn_data/
mkdir -p $EP

bart slice 15 10 valid/col $EP/col
bart slice 15 10 valid/ref $EP/ref
bart copy mask_po_4 $EP/pat
bart slice 15 10 valid/ksp $TDIR/tmp
bart fmac $TDIR/tmp $EP/pat $EP/ksp
bart slice 15 10 valid/ksp_rad $EP/ksp_rad
bart copy trj $EP/trj


EP=$REPO/00_data/01_example_data/02_vn_data_alias/
mkdir -p $EP

bart copy mask_po_4_ali $EP/mask
bart slice 15 10 eval/ksp_ali $EP/ksp1
bart slice 15 35 eval/ksp_ali $EP/ksp2
bart slice 15 10 eval/col_ali1 $EP/col1_1map
bart slice 15 35 eval/col_ali1 $EP/col2_1map
bart slice 15 10 eval/col_ali2 $EP/col1_2map
bart slice 15 35 eval/col_ali2 $EP/col2_2map
bart slice 15 10 eval/ref_ali_fil $EP/cim1
bart slice 15 35 eval/ref_ali_fil $EP/cim2