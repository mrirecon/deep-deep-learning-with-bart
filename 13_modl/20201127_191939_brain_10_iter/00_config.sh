ITERATIONS1=1
ITERATIONS2=10

EPOCHS1=100
EPOCHS2=50

network_opts=""
train_opts="--lowmem -Tbatchgen-shuffle-data,average-loss -b10"

source $REPO/00_data/02_dataset_description/10_brain.sh
