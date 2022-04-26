export OMP_NUM_THREADS=40

TOOLBOX_PATH_PLAIN=/home/mblum/Bart/bart_run/
TOOLBOX_PATH_CUDNN=/home/mblum/Bart/bart_cudnn/

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_06/brain_32_gpu1/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_06/brain_32_gpu1_cudnn/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_06/varnet_knee_gpu1/01_script_train.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_06/varnet_knee_gpu1_cudnn/01_script_train.sh

TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_06/varnet_knee_gpu1/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_PLAIN bash $REPO/Figure_06/brain_32_gpu1/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_06/brain_32_gpu1_cudnn/01_script_train_multigpu.sh
TOOLBOX_PATH=$TOOLBOX_PATH_CUDNN bash $REPO/Figure_06/varnet_knee_gpu1_cudnn/01_script_train_multigpu.sh