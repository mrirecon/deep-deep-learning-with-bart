EPOCHS=30
ITERATIONS=10

network_opts=""
train_opts="-Tbatchgen-shuffle-data,average-loss,dump-mod=1 -b10"

source $REPO/00_data/02_dataset_description/01_knee.sh