source $REPO/00_data/02_dataset_description/10_brain.sh

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT

ITERATIONS=1
HISTORY_FILE=05_history_one_multigpu
EPOCHS=100

weights=10_weights_one

apply_out=$WORKDIR/out1
apply_trj=${eval_trj:=}
apply_pat=${eval_pat:=}
apply_ksp=$eval_ksp
apply_col=$eval_col

source $REPO/00_data/02_dataset_description/00_parse_arguments.sh
$TOOLBOX_PATH/bart reconet -G2 ${LOWMEM=} -Nmodl -I$ITERATIONS -T epochs=$EPOCHS,export-history=$HISTORY_FILE -t $BART_GPU $train_files > log_multigpu.log

ITERATIONS=5
HISTORY_FILE=06_history_multigpu
EPOCHS=50

weights=11_weights

apply_out=$WORKDIR/out2
apply_trj=${eval_trj:=}
apply_pat=${eval_pat:=}
apply_ksp=$eval_ksp
apply_col=$eval_col

source $REPO/00_data/02_dataset_description/00_parse_arguments.sh
$TOOLBOX_PATH/bart reconet -G2 ${LOWMEM=} -Nmodl -I$ITERATIONS -T epochs=$EPOCHS,export-history=$HISTORY_FILE -t $BART_GPU --load=10_weights_one $train_files >> log_multigpu.log
