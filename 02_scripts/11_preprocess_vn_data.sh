#!/bin/bash

set -eu

espirit()
(
	SET=$1
	KSP=$(readlink -f "$2")
	COL=$(readlink -f "$3")

	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	BAT=$(bart show -d15 $KSP)

	export OMP_NUM_THREADS=1

	COLS=
	for i in $(seq 0 $((BAT-1)))
	do
	(
		bart slice 15 $i $KSP ksp_$i
		bart ecalib -O -m$SET ksp_$i col_r_$i
		bart resize -c 0 320 col_r_$i col_$i
	)&
	COLS+=" col_$i"
	done

	wait
	bart join 15 $COLS $COL
)

get_ref()
(
	KSP=$(readlink -f "$1")
	COL=$(readlink -f "$2")
	REF=$(readlink -f "$3")

	FE=$(bart show -d0 $COL)

	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	bart fft -i -u 7 $KSP cim_r
	bart resize -c 0 $FE cim_r cim
	bart fmac -C -s$(bart bitmask 3) cim $COL $REF
)

get_noncart()
(
	KSP=$(readlink -f "$1")
	TRJ=$(readlink -f "$2")
	KSP_NONCART=$(readlink -f "$3")

	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	bart fft -i -u 7 $KSP cim_r
	bart resize -c 0 320 cim_r cim
	bart nufft $TRJ cim $KSP_NONCART
)

get_mask()
(
	MSK=$(readlink -f "$1")

	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	bart ones 1 1 one
	bart zeros 1 3 zero

	bart join 0 one zero pat
	bart repmat 1 92 pat pat2
	bart reshape 3 1 368 pat2 pat3

	bart extract 1 19 170 pat3 pat4
	bart extract 1 198 349 pat3 pat5
	
	bart ones 2 1 19 ones
	bart ones 2 1 28 ones_AC
	
	bart join 1 ones pat4 ones_AC pat5 ones msk2

	bart repmat 0 640 msk2 $MSK
)

get_aliased()
(
	KSP=$(readlink -f "$1")
	KSP_ALI=$(readlink -f "$2")
	CIM_ALI=$(readlink -f "$3")

	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	bart resize -c 1 320 $KSP ksp_1 #remove phase oversampling
	bart fft -u -i 7 ksp_1 cim_1
	bart resize -c 1 440 cim_1 cim_2
	bart fft -u 7 cim_2 ksp_2
	bart reshape $(bart bitmask 1 10) 2 220 ksp_2 ksp_1
	bart transpose 1 10 ksp_1 ksp_2
	bart slice 10 0 ksp_2 $KSP_ALI

	bart fft -i -u 7 $KSP_ALI cim_1
	bart resize -c 0 320 cim_1 $CIM_ALI
)

get_cim_aliased_filtered()
(
	KSP=$(readlink -f "$1")
	CIM=$(readlink -f "$2")
	
	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT
	cd $TDIR

	bart resize -c 1 320 $KSP ksp_1 #remove phase oversampling
	bart fft -u -i 7 ksp_1 cim_2
	bart resize -c 0 320 cim_2 cim_1

	espirit 1 ksp_1 col_1
	bart fmac -C -s$(bart bitmask 3) cim_1 col_1 img_1
	bart fmac img_1 col_1 cim_1

	bart resize -c 1 440 cim_1 cim_2
	bart fft -u 7 cim_2 ksp_2
	bart reshape $(bart bitmask 1 10) 2 220 ksp_2 ksp_1
	bart transpose 1 10 ksp_1 ksp_2
	bart slice 10 0 ksp_2 ksp_1
	bart fft -i -u 7 ksp_1 $CIM
)

join_seq()
(
	START=$1
	STOP=$2
	INPUT=$3
	OUTPUT=$4

	ARGS=""
	for i in $(seq $START $STOP)
	do
		ARGS+=" ${INPUT}_${i}"
	done

	bart join 15 $ARGS $OUTPUT
)

TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$TDIR";' EXIT

mkdir -p $DATA_ARCHIVE/02_vn_data/coronal_pd_fs
cd $DATA_ARCHIVE/02_vn_data/coronal_pd_fs

mkdir -p prep

bart traj -x 368 -y 44 -r trj

for pat in $(seq 20)
do 
(
	TDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$TDIR";' EXIT

	bart extract 13 10 30 ${DATA_PATH_VN_KNEE}/ksp_$pat $TDIR/ksp
	bart reshape $(bart bitmask 13 15) 1 20 $TDIR/ksp prep/ksp_$pat

	bart extract 13 10 30 ${DATA_PATH_VN_KNEE}/col_$pat $TDIR/col
	bart resize -c 0 320 $TDIR/col $TDIR/col_res
	bart reshape $(bart bitmask 13 15) 1 20 $TDIR/col_res prep/col_$pat

	cd prep

	get_ref ksp_$pat col_$pat ref_$pat

	get_noncart ksp_$pat ../trj ksp_rad_$pat

	get_aliased ksp_$pat ksp_ali_$pat ref_ali_$pat
	get_cim_aliased_filtered ksp_$pat ref_ali_fil_$pat

	espirit 1 ksp_ali_$pat col_ali1_$pat
	espirit 2 ksp_ali_$pat col_ali2_$pat
)
done

wait

get_mask mask_po_4
bart resize -c 1 220 mask_po_4 mask_po_4_ali


mkdir -p train

join_seq 1 15 prep/ksp train/ksp
join_seq 1 15 prep/col train/col
join_seq 1 15 prep/ref train/ref
join_seq 1 15 prep/ksp_rad train/ksp_rad
join_seq 1 15 prep/ksp_ali train/ksp_ali
join_seq 1 15 prep/col_ali1 train/col_ali1
join_seq 1 15 prep/col_ali2 train/col_ali2
join_seq 1 15 prep/ref_ali_fil train/ref_ali_fil
join_seq 1 15 prep/ref_ali train/ref_ali

mkdir -p eval

join_seq 16 20 prep/ksp eval/ksp
join_seq 16 20 prep/col eval/col
join_seq 16 20 prep/ref eval/ref
join_seq 16 20 prep/ksp_rad eval/ksp_rad
join_seq 16 20 prep/ksp_ali eval/ksp_ali
join_seq 16 20 prep/col_ali1 eval/col_ali1
join_seq 16 20 prep/col_ali2 eval/col_ali2
join_seq 16 20 prep/ref_ali_fil eval/ref_ali_fil
join_seq 16 20 prep/ref_ali eval/ref_ali

mkdir -p valid

join_seq 16 16 prep/ksp valid/ksp
join_seq 16 16 prep/col valid/col
join_seq 16 16 prep/ref valid/ref
join_seq 16 16 prep/ksp_rad valid/ksp_rad
join_seq 16 16 prep/ksp_ali valid/ksp_ali
join_seq 16 16 prep/col_ali1 valid/col_ali1
join_seq 16 16 prep/col_ali2 valid/col_ali2
join_seq 16 16 prep/ref_ali_fil valid/ref_ali_fil
join_seq 16 16 prep/ref_ali valid/ref_ali