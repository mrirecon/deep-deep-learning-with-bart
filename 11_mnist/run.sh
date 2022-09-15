#!/bin/bash
#Copyright 2022. Uecker Lab. University Medical Center Göttingen.
set -eu
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source ../init.sh

# Training
bart mnist -g -t train_images weights train_labels

# Inference
bart extract 2 0 10 test_images images 
bart mnist -a images weights prediction
bart onehotenc -r prediction label

## Print first 10 predictions
echo Prediction:
bart show label
