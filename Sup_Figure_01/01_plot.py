#!/usr/bin/env python3

import os
import sys
import numpy as np
import cfl

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 11})
width=9.5*5/4

def plot(outfile):

    bart_train = cfl.readcfl(os.environ['REPO'] + "/Sup_Figure_01/history_bart_train").real
    tf_train = cfl.readcfl(os.environ['REPO'] + "/Sup_Figure_01/history_tf_train").real
    
    bart_test = cfl.readcfl(os.environ['REPO'] + "/Sup_Figure_01/history_bart_eval").real
    tf_test = cfl.readcfl(os.environ['REPO'] + "/Sup_Figure_01/history_tf_eval").real

    fig, axs = plt.subplots(2,1,sharex=True, figsize=(8,4))
    ax1=axs[0]
    ax2=axs[1]

    x = np.linspace(0,30,31)
    lin=ax1.plot(x, np.mean(bart_test[:,3,:],axis=-1), label="BART (PSNR)")
    ax1.plot([], [], label="BART (SSIM)", color=lin[0].get_color(), ls="dashed")
    lin=ax1.plot(x, np.mean(tf_test[:,3,:],axis=-1), label="TensorFlow")
    ax1.plot([], [], label="TensorFlow (SSIM)", color=lin[0].get_color(), ls="dashed")

    ax1.set_ylim(27,37)
    ax1.legend(loc="lower right", ncol=2)

    ax1.set_ylabel("PSNR [dB]")
    ax2.set_xlabel("Epochs")

    ax1=ax1.twinx()

    ax1.plot(x, np.mean(bart_test[:,2,:],axis=-1), ls="dashed")
    ax1.plot(x, np.mean(tf_test[:,2,:],axis=-1),ls="dashed")

    ax1.set_ylim(0.75,0.9)
    ax1.set_ylabel("SSIM")

    lin=ax2.plot(x, np.mean(bart_train[:,1,:],axis=-1), label="BART (train)")
    ax2.plot(x, np.mean(bart_test[:,1,:],axis=-1), label="BART (eval)", color=lin[0].get_color(), ls="dashed")
    lin=ax2.plot(x, np.mean(tf_train[:,1,:],axis=-1), label="TensorFlow (train)")
    ax2.plot(x, np.mean(tf_test[:,1,:],axis=-1), label="TensorFlow (eval)", color=lin[0].get_color(), ls="dashed")
    
    ax2.set_ylim(0.5e-11,1.1e-11)
    ax2.set_ylabel("MSE (magnitude)")
    ax2.legend(loc="upper right", ncol=2)

    plt.tight_layout()
    plt.savefig(outfile, dpi=600)
    plt.close()

if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)