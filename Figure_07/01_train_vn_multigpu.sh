source $REPO/00_data/02_dataset_description/01_knee.sh
source $REPO/Figure_06/00_time.sh

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT

weights=11_weights
source $REPO/00_data/02_dataset_description/00_parse_arguments.sh

apply_out=$WORKDIR/out
apply_trj=${eval_trj:=}
apply_pat=${eval_pat:=}
apply_ksp=$eval_ksp
apply_col=$eval_col

ITERATIONS=10
HISTORY_FILE=06_history_multigpu
EPOCHS=30

weights=11_weights
source $REPO/00_data/02_dataset_description/00_parse_arguments.sh

$TOOLBOX_PATH/bart reconet -G2 ${NORMALIZE=} -Nvarnet -t -I$ITERATIONS -T epochs=$EPOCHS,export-history=$HISTORY_FILE -t $BART_GPU $train_files > log_multigpu.log