#!/bin/bash
set -eu

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPTPATH

# Set environment variables
source init.sh

# Download data
bash 02_scripts/01_load_vn_data.sh
bash 02_scripts/02_load_modl_data.sh
bash 02_scripts/03_load_example_data.sh

# Preprocess training data
bash 02_scripts/11_preprocess_vn_data.sh

python3 02_scripts/12_convert_modl_data.py
bash 02_scripts/13_preprocess_modl_data.sh

# Deterministic gridding
export OMP_NUM_THREADS=1

# Train networks
bash 12_varnet/train_all.sh
bash 13_modl/train_all.sh

# Delete figures and metrics
make allclean

# Recreate figures
make
make Figure_08/figure_08_tensorflow.pdf
make Figure_08/figure_08_tensorflow.png
make Sup_Figure_01/sup_figure_01.pdf
make Sup_Figure_01/sup_figure_01.png