#!/bin/bash
set -eu

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

# Set environment variables
source init.sh

# Download data
bash 02_scripts/03_load_example_data.sh
bash 02_scripts/04_load_weights.sh

# Delete figures
make clean

# Recreate figures
make
make Figure_08/figure_08_tensorflow.pdf
make Figure_08/figure_08_tensorflow.png
make Sup_Figure_01/sup_figure_01.pdf
make Sup_Figure_01/sup_figure_01.png