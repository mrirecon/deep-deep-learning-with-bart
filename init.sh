if [ -z "${TOOLBOX_PATH+x}" ]
then
echo "WARNING: TOOLBOX_PATH is not set!
Make sure that BART is in your PATH variable."
else
	echo "TOOLBOX_PATH is set to $TOOLBOX_PATH"
	export PATH=${TOOLBOX_PATH}:${PATH}
	PYTHONPATH=${PYTHONPATH=}
	export PYTHONPATH="${TOOLBOX_PATH}/python:${PYTHONPATH:-}"
fi

echo "BART at $(which bart) ($(bart version))"

export REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/"
echo "REPO is set to $REPO"

if [ -z "${DATA_DIR+x}" ]
then
echo "WARNING: DATA_DIR is created in this repository!
It is recommended to use a scratch directory."
	export DATA_DIR=$REPO/00_data/00_data_archive/
fi
echo "DATA_DIR is set to $DATA_DIR"

export BART_GPU=-g

# DATA_ARCHIVE is used for internal reproducibility testing
#
if [ ! -z "${DATA_ARCHIVE+x}" ] ; then

	REPO_NAME=$(<"$REPO"/meta/name)
	if [ -d ${DATA_ARCHIVE}/${REPO_NAME} ] ; then
		DATA_PATH_VN_KNEE=${DATA_ARCHIVE}/${REPO_NAME}/raw_knee/
		DATA_PATH_MODL_BRAIN=${DATA_ARCHIVE}/${REPO_NAME}/brain_data.hdf5
	fi
fi

download()
(
	URL=$1
	DST=$2

	if [ ! -f "$DST" ] && [ ! -z "${DATA_ARCHIVE+x}" ] ; then
		
		REPO_NAME=$(<"$REPO"/meta/name)
		if [ -f ${DATA_ARCHIVE}/${REPO_NAME}/$DST ] ; then
			cp ${DATA_ARCHIVE}/${REPO_NAME}/$DST $DST
		fi
	fi

	if [ ! -f "$DST" ]; then
		TMPFILE=$(mktemp)
   		wget -O $TMPFILE $URL
		mv $TMPFILE $DST
	fi
)


#path to downloaded data from variational network / MoDL
echo "VarNet raw-data path is set to ${DATA_PATH_VN_KNEE:=$DATA_DIR/02_vn_data/coronal_pd_fs/raw/}"
echo "MoDL raw-data path is set to ${DATA_PATH_MODL_BRAIN:=$DATA_DIR/03_modl_data/raw/dataset.hdf5}"

export DATA_PATH_VN_KNEE
export DATA_PATH_MODL_BRAIN
export BART_COMPAT_VERSION=v0.8.00
