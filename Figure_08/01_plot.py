#!/usr/bin/env python3

import os
import sys
import numpy as np
import cfl

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 12})
width=9.5

def plot(outfile):

    out_adj_60 = cfl.readcfl("reco_adj_60")
    out_l1e_60 = cfl.readcfl("reco_l1esp_60")
    out_tfp_60 = cfl.readcfl("reco_tfp_60")

    out_adj_60 = out_adj_60[:,::-1] / np.max(np.abs(out_adj_60))
    out_l1e_60 = out_l1e_60[:,::-1] / np.max(np.abs(out_l1e_60))
    out_tfp_60 = out_tfp_60[:,::-1] / np.max(np.abs(out_tfp_60))

    out_adj_60_zoom = out_adj_60[100:-100,50:-50]
    out_l1e_60_zoom = out_l1e_60[100:-100,50:-50]
    out_tfp_60_zoom = out_tfp_60[100:-100,50:-50]

    zoom_ratio = out_adj_60_zoom.shape[0] / out_adj_60_zoom.shape[1]

    fig, axes = plt.subplots(2, 3, tight_layout=True, figsize=(width , width / 2.), gridspec_kw={'height_ratios': [1, zoom_ratio]})

    scale = 0.9

    axes[0,0].set_title("Inverse NuFFT")
    axes[0,1].set_title("$\ell_1$-Wavelet PICS")
    axes[0,2].set_title("TensorFlow Prior")

    axes[1,0].imshow(np.abs(out_adj_60_zoom), extent=[0, 1, 0, zoom_ratio], vmin = 0, vmax=scale, cmap="gray")
    axes[1,1].imshow(np.abs(out_l1e_60_zoom), extent=[0, 1, 0, zoom_ratio], vmin = 0, vmax=scale, cmap="gray")
    axes[1,2].imshow(np.abs(out_tfp_60_zoom), extent=[0, 1, 0, zoom_ratio], vmin = 0, vmax=scale, cmap="gray")

    axes[0,0].imshow(np.abs(out_adj_60), extent=[0, 1, 0, 1], vmin = 0, vmax=scale, cmap="gray")
    axes[0,1].imshow(np.abs(out_l1e_60), extent=[0, 1, 0, 1], vmin = 0, vmax=scale, cmap="gray")
    axes[0,2].imshow(np.abs(out_tfp_60), extent=[0, 1, 0, 1], vmin = 0, vmax=scale, cmap="gray")

    for ax in axes.flatten():
        ax.set_xticks([])
        ax.set_yticks([])

    plt.savefig(outfile, dpi=600)
    plt.close()

if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)


# %%
