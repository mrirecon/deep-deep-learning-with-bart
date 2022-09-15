# Deep, deep learning with BART

This repository supports the manuscript *Deep, deep learning with BART*. It contains scripts to prepare data for training the BART implementations of the Varaiational Network and MoDL. Moreover, the figures presented in the manuscript can be reproduced using this repository.

The training and the creation of the figures can be reproduced by running the script
```bash
bash reproduce_all.sh
```
Note that this script also downloads all the training data.
If you only want to reproduce the figures, you can download the pretrained weights and example data by running
```bash
bash reproduce_figs.sh
```
In the following sections, we descibe the requirements and individual steps involving the reproduction of the figures.
## Requirements

This repository has been tested on Debian 11 but is assumed to work on other Linux based operating systems.  
**Python** is used to convert data to the BART file format and for plotting.
We require **numpy**, **scipy**, **h5py** and **matplotlib** to be installed.

To download and unzip pretrained data **wget** and **unzip** are used.
### BART
needs to be installed in the current version (c.f. https://mrirecon.github.io/bart/).
We strongly recommend to compile BART with GPU support. For reconstructions using the TensorFlow prior, the TensorFlow for C library is required.
Please follow the instructions at https://www.tensorflow.org/install/lang_c to install the library.

Further suggested compile options for performance reasons are:
+ NON_DETERMINISTIC?=1 (will be faster, allows atomic, non-deterministic operations on the GPU, i.e. weights cannot be reproduced)
+ CUDNN?=1 (optionally, requires cuDNN to be installed)

To use these compile options, you can run
```bash
echo "CUDA?=1">>Makefiles/Makefile.local
echo "NON_DETERMINISTIC?=1">>Makefiles/Makefile.local

echo "TENSORFLOW=1">>Makefiles/Makefile.local
echo "TENSORFLOW_BASE=<path_to_tensorflow_lib>">>Makefiles/Makefile.local
```
in your BART directory to add the options to your local Makefile.
Make sure that the environment variable `TOOLBOX_PATH` points to the BART directory.

## Environment Variables

The scripts in this repository make use of environment variables to store the pathes to various datasets:
* **REPO**: The path to this repository
* **DATA_DIR**: The path to a directory containing the preprocessed training data
* **DATA_PATH_VN_KNEE**: The path to a directory containing the downloaded rawdata of the Variational Network
* **DATA_PATH_MODL_BRAIN** The path to the MoDL raw data *dataset.hdf5*

You can set default variables by running
this repository:
```bash
source init.sh # Set REPO variable and add BART to PYTHON_PATH
```

## Data

### Training Data 
We use the data provided with the original implementations of the Variational Network and MoDL.
The data for the Variational Network (converted to the BART format) can be downloaded from :
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6482961.svg)](https://doi.org/10.5281/zenodo.6482961)

The data for MoDL can be downloaded from: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6481291.svg)](https://doi.org/10.5281/zenodo.6481291)

Conversion and preprocessing of training data is performed by running (training data is only required if you want to retrain the networks):

```bash
cd $REPO

#download data
bash 02_scripts/01_load_vn_data.sh
bash 02_scripts/02_load_modl_data.sh

#convert data
bash 02_scripts/11_preprocess_vn_data.sh
python3 02_scripts/12_preprocess_modl_data.sh
```

The preprocessed training data for all experiments requires about 150 GB!

### Example Data
We provide the preprocessed example data used for the reconstruction presented in the figures at [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7002209.svg)](https://doi.org/10.5281/zenodo.7002209).
```bash
cd $REPO
bash 02_scripts/03_load_example_data.sh
```

## Reproduce Training
If you just want to reproduce the figures, you can download the pretrained weights using
```bash
cd $REPO
bash 02_scripts/04_load_weights.sh
```
Alternatively, if you want to retrain the networks, run
```bash
cd $REPO
bash 12_varnet/train_all.sh
bash 13_modl/train_all.sh
```

For each directory in *12_varnet* and *13_modl*, this will generate the following files:
+ `03_log.log`: the command line output of the `bart reconet` command
+ `06_history.hdr/cfl`: the training history, the dimensions represent:
	1. epoch
	2. batch
	3. index 0: value is aquired or not; index 1: actual value
	4. different values of the training process:
		0. time (in the current epoch)
		1. loss
		2. other values as printed in the log file
+ `11_weights.hdr/cfl`: the trained weights
+ `24_eval.log`: output from `bart reconet --eval` on the evaluation data set
+ `34_reco_valid.hdr/cfl/png`: reconstruction of the validation data set using the trained weights.

## Recreate Figures

All reconstructions and figures based on them are created using the `Makefile` in the root directory.
To recreate the figures run:

```bash
cd $REPO
make clean # delete figures
make allclean # delete evaluation metrics (only run this if you have downloaded the full training dataset)
make # Create all figures except the one requiering TensorFlow
make Figure_08/figure_08_tensorflow.pdf # Create the TensorFlow based figure
```
## Manual Training

If you want to train and apply the networks directly in the command line, you can run the following commands:

### Variational Network
```bash
# set path to converted training data
DP=$DATA_DIR/02_vn_data/coronal_pd_fs/

# train
bart reconet --varnet --train --normalize \
	-Tepochs=30 \
	--pattern=$DP/mask_po_4 \
	$DP/train/ksp $DP/train/col weights_vn $DP/train/ref

# apply
bart reconet --varnet --apply --normalize \
	--pattern=$DP/mask_po_4 \
	$DP/valid/ksp $DP/valid/col weights_vn reco_vn
```

### Modl
```bash
# set path to converted training data
DP=$DATA_DIR/03_modl_data/ 

# train
bart reconet --modl --train \
	-Tepochs=100 \
	--pattern=$DP/train/pat \
	$DP/train/ksp $DP/train/col weights_modl_init $DP/train/ref

bart reconet --modl --train \
	-Tepochs=50 \
	--load=weights_modl_init \
	--pattern=$DP/train/pat \
	$DP/train/ksp $DP/train/col weights_modl $DP/train/ref

# apply
bart reconet --modl --apply \
	--pattern=$DP/valid/pat \
	$DP/valid/ksp $DP/valid/col weights_modl reco_modl
```

# Toy Example
For interested programmers, we have implemented an MNIST-network in BART. It is stripped down to the absolute necessary to train and apply a neural network.
The source code can be found at `src/mnist.c` in the BART directory or on [GitHub](https://github.com/mrirecon/bart/blob/master/src/mnist.c). In this repository, scripts to download/preprocess the MNIST-dataset and to train/infer the network can be found in this repository in the directory `11_mnist`.
