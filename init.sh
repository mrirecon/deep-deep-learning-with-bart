if [ -z "${TOOLBOX_PATH+x}" ]
then
echo "WARNING: TOOLBOX_PATH is not set!
Make sure that BART is in your PATH variable."
else
	echo "TOOLBOX_PATH is set to $TOOLBOX_PATH"
	export PATH=${TOOLBOX_PATH}:${PATH}
	PYTHONPATH=${PYTHONPATH=}
	export PYTHONPATH="${TOOLBOX_PATH}/python:$PYTHONPATH"
fi

echo "BART at $(which bart) ($(bart version))"

export REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"
echo "REPO is set to $REPO"

if [ -z "${DATA_ARCHIVE+x}" ]
then
echo "WARNING: DATA_ARCHIVE is created in this repository!
It is recommended to use a scratch directory."
	export DATA_ARCHIVE=$REPO/00_data/00_data_archive/
fi
echo "DATA_ARCHIVE is set to $DATA_ARCHIVE"

export BART_GPU=-g

#path to downloaded data from variational network / MoDL
echo "VarNet raw-data path is set to ${DATA_PATH_VN_KNEE:=$DATA_ARCHIVE/02_vn_data/raw/}"
echo "MoDL raw-data path is set to ${DATA_PATH_MODL_BRAIN:=$DATA_ARCHIVE/03_modl_data/raw/dataset.hdf5}"

export DATA_PATH_VN_KNEE
export DATA_PATH_MODL_BRAIN