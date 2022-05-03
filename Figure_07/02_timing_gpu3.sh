TOOLBOX_PATH_PLAIN=/home/mblum/Bart/bart_run/
TOOLBOX_PATH_CUDNN=/home/mblum/Bart/bart_cudnn/

export CUDA_VISIBLE_DEVICES=1
export OMP_NUM_THREADS=40

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/brain_32_gpu3/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/brain_32_gpu3_cudnn/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/varnet_knee_gpu3/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/varnet_knee_gpu3_cudnn/01_script_train.sh

export CUDA_VISIBLE_DEVICES=1,2

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/varnet_knee_gpu3/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/brain_32_gpu3/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/brain_32_gpu3_cudnn/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/varnet_knee_gpu3_cudnn/01_script_train_multigpu.sh