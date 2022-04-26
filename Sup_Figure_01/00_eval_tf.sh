

source $REPO/00_data/02_dataset_description/01_knee.sh
set -eu

OUT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

bart rss 8 $train_col scl

MEAS=""

for i in $(seq 0 30 900)
do
    WGH=$REPO/00_data/01_example_data/mri_vn_2022-01-15--00-39-01/checkpoints_bart/wgh-$i

    bart reconet --network=varnet --apply -I10  ${BART_GPU=} --normalize --pattern=$train_pat $train_ksp $train_col $WGH out1
    bart fmac out1 scl out

    bart measure --mse out $train_ref mse
    bart measure --mse-mag out $train_ref msemag
    bart measure --ssim out $train_ref ssim
    bart measure --psnr out $train_ref psnr

    bart join 1 mse msemag ssim psnr meas
    bart reshape $(bart bitmask 2 15) $(bart show -d 15 meas) 1 meas meas_$i

    MEAS+=" meas_$i"
done

bart join 0 $MEAS $OUT_DIR/history_tf_train


bart rss 8 $eval_col scl

MEAS=""

for i in $(seq 0 30 900)
do
    WGH=$REPO/00_data/01_example_data/mri_vn_2022-01-15--00-39-01/checkpoints_bart/wgh-$i

    bart reconet --network=varnet --apply -I10  ${BART_GPU=} --normalize --pattern=$eval_pat $eval_ksp $eval_col $WGH out1
    bart fmac out1 scl out

    bart measure --mse out $eval_ref mse
    bart measure --mse-mag out $eval_ref msemag
    bart measure --ssim out $eval_ref ssim
    bart measure --psnr out $eval_ref psnr

    bart join 1 mse msemag ssim psnr meas
    bart reshape $(bart bitmask 2 15) $(bart show -d 15 meas) 1 meas meas_$i

    MEAS+=" meas_$i"
done

bart join 0 $MEAS $OUT_DIR/history_tf_eval