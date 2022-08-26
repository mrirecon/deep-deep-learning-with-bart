#!/usr/bin/env python3

import os
import os.path
import sys
import numpy as np
import cfl

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 12})
width=9.5


# %%

def get_time(file):
    time=0.
    try:
        hist = cfl.readcfl(file)
        time = np.sum(hist[:,-1,1,0])
    except:
        pass
    return np.real(time) / 60

# %%

def plot(outfile):

    gpus = [ "GeForce GTX TITAN X", "TITAN Xp", "Tesla V100-SXM2-32GB", "A100-SXM-80GB"]
    gpus = [ "TITAN X", "TITAN Xp", "V100", "A100"]

    vn_train_tf_old=np.array([
        325,
        238, 
        0,
        0
    ])

    vn_train_tf=np.array([
        21610,
        19550,
        8340,
        5227
    ]) / 60

    modl_train_tf=np.array([
        46,
        50,
        30,
        21
    ])           #in minutes

    vn_apply_tf=np.array([
        125,
        125,
        95,
        91
    ]) / 0.1     #in ms/slice
    
    modl_apply_tf=np.array([
        14,
        12,
        14,
        14
    ]) / 0.164   #in seconds

    vn_apply_tf_gpu=np.array([
        3.8/0.19,
        2.0/0.17,
        0.75/0.13,
        0.82/0.22
        ]) / 0.1    #in ms/slice

    modl_apply_tf_gpu=np.array([
        1.7/0.15,
        0.86/0.13,
        0.59/0.16,
        0.38/0.15
    ])/0.164  #in ms/slice


    vn_bart_plain=np.array([
        get_time("varnet_knee_gpu3/06_history"),
        get_time("varnet_knee_gpu2/06_history"),
        get_time("varnet_knee_gpu1/06_history"),
        get_time("varnet_knee_gpu4/06_history"),
    ])
    vn_bart_cudnn=np.array([
        get_time("varnet_knee_gpu3_cudnn/06_history"),
        get_time("varnet_knee_gpu2_cudnn/06_history"),
        get_time("varnet_knee_gpu1_cudnn/06_history"),
        get_time("varnet_knee_gpu4_cudnn/06_history"),
    ])

    modl_bart_plain=np.array([
        get_time("brain_32_gpu3/06_history"),
        get_time("brain_32_gpu2/06_history"),
        get_time("brain_32_gpu1/06_history"),
        get_time("brain_32_gpu4/06_history"),
    ])
    modl_bart_cudnn=np.array([
        get_time("brain_32_gpu3_cudnn/06_history"),
        get_time("brain_32_gpu2_cudnn/06_history"),
        get_time("brain_32_gpu1_cudnn/06_history"),
        get_time("brain_32_gpu4_cudnn/06_history"),
    ])


    vn_bart_plain_multigpu=np.array([
        get_time("varnet_knee_gpu3/06_history_multigpu"),
        get_time("varnet_knee_gpu2/06_history_multigpu"),
        get_time("varnet_knee_gpu1/06_history_multigpu"),
        get_time("varnet_knee_gpu4/06_history_multigpu"),
    ])
    vn_bart_cudnn_multigpu=np.array([
        get_time("varnet_knee_gpu3_cudnn/06_history_multigpu"),
        get_time("varnet_knee_gpu2_cudnn/06_history_multigpu"),
        get_time("varnet_knee_gpu1_cudnn/06_history_multigpu"),
        get_time("varnet_knee_gpu4_cudnn/06_history_multigpu"),
    ])

    modl_bart_plain_multigpu=np.array([
        get_time("brain_32_gpu3/06_history_multigpu"),
        get_time("brain_32_gpu2/06_history_multigpu"),
        get_time("brain_32_gpu1/06_history_multigpu"),
        get_time("brain_32_gpu4/06_history_multigpu"),
    ])
    modl_bart_cudnn_multigpu=np.array([
        get_time("brain_32_gpu3_cudnn/06_history_multigpu"),
        get_time("brain_32_gpu2_cudnn/06_history_multigpu"),
        get_time("brain_32_gpu1_cudnn/06_history_multigpu"),
        get_time("brain_32_gpu4_cudnn/06_history_multigpu"),
    ])

    for i in range(4):
        print(modl_bart_plain_multigpu[i] / modl_bart_plain[i])
        print(modl_bart_cudnn_multigpu[i] / modl_bart_cudnn[i])

    
    for i in range(4):
        print(vn_bart_plain_multigpu[i] / vn_bart_plain[i])
        print(vn_bart_cudnn_multigpu[i] / vn_bart_cudnn[i])



    vn_bart_apply_plain=np.array([
        68,
        29,
        23,
        12
    ])/0.1

    vn_bart_apply_plain_gpu=np.array([
        6.7/0.21,
        3.4/0.18,
        1.7/0.18,
        1.4/0.27
    ])/0.1



    vn_bart_apply_cudnn=np.array([
        35,
        28,
        16,
        14
    ])/0.1

    vn_bart_apply_cudnn_gpu=np.array([
        6.7/0.24,
        3.4/0.22,
        1.7/0.20,
        1.4/0.23
    ])/0.1



    modl_bart_apply_plain=np.array([
        27,
        21,
        14,
        13
    ])/0.164

    modl_bart_apply_plain_gpu=np.array([
        3.9/0.23,
        2.1/0.22,
        1.1/0.20,
        0.65/0.20
    ])/0.164



    modl_bart_apply_cudnn=np.array([
        25,
        21,
        14,
        16
    ])/0.164

    modl_bart_apply_cudnn_gpu=np.array([
        2.2/0.15,
        1.1/0.14,
        0.57/0.12,
        0.41/0.13
    ])/0.164


    N = (len(gpus))
    ind = np.arange(N)
    barwidth = 0.28

    fig, axes = plt.subplots(2, 2, sharey = True, figsize=(width, width / 2.))




    axes[0][0].barh(ind + 1.5*barwidth, modl_bart_plain, barwidth, label='BART', color="#CEE0ED")
    axes[0][0].barh(ind + 0.5*barwidth, modl_bart_cudnn, barwidth, label='BART (cuDNN)', color="#b3cde3")

    axes[0][0].barh(ind + 1.5*barwidth, modl_bart_plain_multigpu, barwidth, label="- with 2 GPUs", fill=False, hatch="//////", edgecolor="0.7", lw=0)
    axes[0][0].barh(ind + 0.5*barwidth, modl_bart_cudnn_multigpu, barwidth, fill=False, hatch="//////", edgecolor="0.7", lw=0)

    axes[0][0].barh(ind - 0.5*barwidth , modl_train_tf, barwidth, label='TensorFlow', color ="#fbb4ae")


    axes[1][0].barh(ind + 1.5*barwidth, vn_bart_plain, barwidth, label='BART', color="#CEE0ED")
    axes[1][0].barh(ind + 0.5*barwidth, vn_bart_cudnn, barwidth, label='BART (cuDNN)', color="#b3cde3")

    axes[1][0].barh(ind + 1.5*barwidth, vn_bart_plain_multigpu, barwidth, label="- with 2 GPUs", fill=False, hatch="//////", edgecolor="0.7", lw=0)
    axes[1][0].barh(ind + 0.5*barwidth, vn_bart_cudnn_multigpu, barwidth, fill=False, hatch="//////", edgecolor="0.7", lw=0)

    axes[1][0].barh(ind - 0.5*barwidth, vn_train_tf,        barwidth, label='TensorFlow', color ="#fbb4ae")
    axes[1][0].barh(ind - 0.5*barwidth, vn_train_tf_old,    barwidth, label="TensorFlow-ICG", color ="#fbb4ae", edgecolor="red", ls="dashed", lw=0.5)



    axes[0][1].barh(ind + 1.5*barwidth, modl_bart_apply_plain,  barwidth, label='BART', color="#CEE0ED")
    axes[0][1].barh(ind + 0.5*barwidth, modl_bart_apply_cudnn,  barwidth, label='BART (cuDNN)', color="#b3cde3")
    axes[0][1].barh(ind - 0.5*barwidth, modl_apply_tf,          barwidth, label='TensorFlow', color ="#fbb4ae")

    axes[0][1].barh(ind + 1.5*barwidth, modl_bart_apply_plain_gpu,  barwidth, label='GPU time only', fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)
    axes[0][1].barh(ind + 0.5*barwidth, modl_bart_apply_cudnn_gpu,  barwidth, fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)
    axes[0][1].barh(ind - 0.5*barwidth, modl_apply_tf_gpu,          barwidth, fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)

    axes[1][1].barh(ind + 1.5*barwidth, vn_bart_apply_plain,  barwidth, label='BART', color="#CEE0ED")
    axes[1][1].barh(ind + 0.5*barwidth, vn_bart_apply_cudnn,  barwidth, label='BART (cuDNN)', color="#b3cde3")
    axes[1][1].barh(ind - 0.5*barwidth, vn_apply_tf,          barwidth, label='TensorFlow', color ="#fbb4ae")

    axes[1][1].barh(ind + 1.5*barwidth, vn_bart_apply_plain_gpu,  barwidth, label='GPU time only', fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)
    axes[1][1].barh(ind + 0.5*barwidth, vn_bart_apply_cudnn_gpu,  barwidth, fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)
    axes[1][1].barh(ind - 0.5*barwidth, vn_apply_tf_gpu,          barwidth, fill=False, hatch="\\\\\\\\\\\\", edgecolor="0.7", lw=0)



    #tmp = axes[0][1].barh(ind + barwidth, modl_bart_apply_plain_gpu, barwidth, label='BART', color="#b3cde3")
    #axes[0][1].barh(ind + barwidth, modl_bart_apply_plain - modl_bart_apply_plain_gpu, barwidth, left = modl_bart_apply_plain_gpu, color="#CEE0ED")
    #tmp = axes[0][1].barh(ind, modl_apply_tf_gpu, barwidth, label='TensorFlow', color="#fbb4ae")
    #axes[0][1].barh(ind, modl_apply_tf - modl_apply_tf_gpu, barwidth, left= modl_apply_tf_gpu, color ="#fbb4ae99")
    #
    #tmp = axes[1][1].barh(ind + barwidth, vn_bart_apply_plain_gpu, barwidth, label='BART', color="#b3cde3")
    #axes[1][1].barh(ind + barwidth, vn_bart_apply_plain - vn_bart_apply_plain_gpu, barwidth, left = vn_bart_apply_plain_gpu, label='BART', color="#CEE0ED")
    #tmp = axes[1][1].barh(ind, vn_apply_tf_gpu, barwidth, label='TensorFlow', color="#fbb4ae")
    #axes[1][1].barh(ind, vn_apply_tf - vn_apply_tf_gpu, barwidth, left= vn_apply_tf_gpu, label='TensorFlow', color ="#fbb4ae99")


    plt.yticks(ind + barwidth / 2, gpus)
    #plt.ylim(-0.5, 4.5)

    axes[1][0].set_title("VarNet - Training")
    axes[0][0].set_title("MoDL - Training")

    axes[1][1].set_title("VarNet - Inference")
    axes[0][1].set_title("MoDL - Inference")

    #axes[0][0].set_xlabel('Training Time [min]')
    axes[1][0].set_xlabel('Time [min]')
    axes[1][1].set_xlabel('Time/Slice [ms]')

    axes[0][0].legend(loc='best', prop={'size': 8})
    axes[1][0].legend(loc='best', prop={'size': 8})
    
    axes[0][1].legend(loc='best', prop={'size': 8})
    axes[1][1].legend(loc='best', prop={'size': 8})
    plt.tight_layout()

    plt.savefig(outfile, dpi=600)
    plt.close()


if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)
# %%
