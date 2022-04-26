EPOCHS=30
ITERATIONS=10

network_opts="--initial-reco tickhonov,max-cg-iter=30"
train_opts="-Tbatchgen-shuffle-data,average-loss -b10 -Tlearning-rate=0.001 --data-consistency lambda-init=0.02"

source $REPO/00_data/02_dataset_description/03_knee_radial.sh