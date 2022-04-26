ITERATIONS1=1
ITERATIONS2=5

EPOCHS1=100
EPOCHS2=50

network_opts="--initial-reco tickhonov,fix-lambda=0.1,max-cg-iter=30 --data-consistency max-cg-iter=30"
train_opts="--lowmem -Tbatchgen-shuffle-data,average-loss -b10"

source $REPO/00_data/02_dataset_description/03_knee_radial.sh