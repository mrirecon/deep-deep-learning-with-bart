#!/bin/bash
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

reco()
(
	export CUDA_VISIBLE_DEVICES="-1"
	export TF_NUM_INTEROP_THREADS=4
	export TF_NUM_INTRAOP_THREADS=4

	usage="Usage: $0 <ksp> <trj> <adj> <l1esp> <tfprior>"

	if [ $# -lt 5 ] ; then

        	echo "$usage" >&2
        	exit 1
	fi

	KSP=$(readlink -f "$1")
	TRJ=$(readlink -f "$2")
	ADJ=$(readlink -f "$3")
	ESP=$(readlink -f "$4")
	TFP=$(readlink -f "$5")
	COL=col

	#WORKDIR=$(mktemp -d)
	# Mac: http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
	WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
	trap 'rm -rf "$WORKDIR"' EXIT
	cd $WORKDIR

	FRE=$(bart show -d 1 $KSP)
	SPK=$(bart show -d 2 $KSP)

	#Weights for density compensation
	NOR=$(echo "2 / ($FRE - 1)" | bc -l)
	bart traj -r -x$FRE -y$SPK -D -c -G -s7 trj
	bart scale $NOR trj trj_s
	bart rss 1 trj_s trj_sa
	bart spow 0.5 trj_sa wgh

	#Coil Sensitivity maps
	bart nufft -i $TRJ $KSP cim
	bart fft 3 cim ksp_grd
	bart ecalib -r20 -m1 -c0.0001 ksp_grd $COL

	bart fmac -C -s$(bart bitmask 3) cim $COL $ADJ

	bart pics -R W:3:0:0.001 -i100 -e -t $TRJ $KSP $COL $ESP

	bart pics -i30 -d5 -R TF:{$REPO/00_data/01_example_data/04_tensorflow_prior/prior/pixel_cnn}:8 -I -e -p wgh -t $TRJ $KSP $COL $TFP
)

DP=$REPO/00_data/01_example_data/04_tensorflow_prior/

reco $DP/ksp_60 $DP/trj_60 reco_adj_60 reco_l1esp_60 reco_tfp_60