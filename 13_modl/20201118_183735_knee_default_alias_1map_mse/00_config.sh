ITERATIONS1=1
ITERATIONS2=5

EPOCHS1=100
EPOCHS2=50

network_opts=""
train_opts="--train-loss=mse=1. --lowmem -Tbatchgen-shuffle-data -b10"

source $REPO/00_data/02_dataset_description/04_knee_alias_1.sh