EPOCHS=30
ITERATIONS=10

network_opts=""
train_opts="--train-loss=mse=1. -Tbatchgen-shuffle-data -b10"

source $REPO/00_data/02_dataset_description/04_knee_alias_1.sh