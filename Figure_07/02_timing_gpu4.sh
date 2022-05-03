TOOLBOX_PATH_PLAIN=/home/mblum/Bart/bart_run/
TOOLBOX_PATH_CUDNN=/home/mblum/Bart/bart_cudnn/

export OMP_NUM_THREADS=40

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/brain_32_gpu4/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/brain_32_gpu4_cudnn/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/varnet_knee_gpu4/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/varnet_knee_gpu4_cudnn/01_script_train.sh

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/brain_32_gpu4/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_07/varnet_knee_gpu4/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/brain_32_gpu4_cudnn/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_07/varnet_knee_gpu4_cudnn/01_script_train_multigpu.sh