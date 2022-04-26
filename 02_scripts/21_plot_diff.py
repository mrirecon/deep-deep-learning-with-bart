#!/usr/bin/env python3

import os
import sys

sys.path.append(os.environ['TOOLBOX_PATH'] + "/python")
import cfl

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def ssim(reco, ref, K1=0.01, K2=0.03):

    import skimage.metrics
    L = np.max(np.abs(ref))
    return skimage.metrics.structural_similarity(np.abs(reco), np.abs(ref), win_size=7, data_range=L, K1=K1, K2=K2, use_sample_covariance=True)

def psnr(reco, ref):

    L = np.max(np.abs(ref))
    mse = np.mean((np.abs(reco) - np.abs(ref))**2)

    return 20 * np.log10(L) - 10 * np.log10(mse)

def plot_difference(reco, ref, out_file):

    sh = reco.shape

    reco=np.abs(reco)
    ref=np.abs(ref)

    if (1 < reco.shape[3]):
        reco=np.sqrt(np.sum(reco*reco, axis=3))
    
    if (1 < ref.shape[3]):
        ref=np.sqrt(np.sum(ref*ref, axis=3))

    reco = reco.reshape([sh[0], sh[1], sh[2], sh[3], sh[-1]])
    ref = ref.reshape([sh[0], sh[1], sh[2], sh[3], sh[-1]])

    plot_diff = True

    max_col=5
    row_per_image=3
    size = 3.5

    no_plots = reco.shape[4]

    col = min(no_plots, max_col)
    row = 1 + (no_plots - 1) // col

    size = size * col

    ratio = ref.shape[0] * row_per_image * row / (ref.shape[1] * col)
    ratio = ratio * 1.1 #title


    fig, axes = plt.subplots(row_per_image * row, col, tight_layout=True, sharex=True, sharey=True, figsize=(size, size * ratio))
    axes = axes.flatten()

    def get_ref_index(i):
        return i % col + row_per_image * col * (i // col)

    def get_reco_index(i):
        return i % col + row_per_image * col * (i // col) + col

    def get_diff_index(i):
        return i % col + row_per_image * col * (i // col) + 2 * col


    for i in range(ref.shape[4]):

        ax_ref = axes[get_ref_index(i)]
        ax_reco = axes[get_reco_index(i)]

        ref_abs = np.abs(ref[:,:, 0, 0, i])
        reco_abs = np.abs(reco[:,:, 0, 0, i])

        ref_sl = ref[::-1,::-1, 0, 0, i]
        reco_sl = reco[::-1,::-1, 0, 0, i]

        scale = np.max(ref_abs)

        ref_abs = ref_abs / scale
        reco_abs = reco_abs / scale

        diff = reco_abs - ref_abs

        ax_ref.set_title("Reference " + str(i))
        ax_reco.set_title("Reco {:d}\nssim: {:.2f}; psnr: {:.1f} (mag)".format(i, ssim(reco_abs, ref_abs), psnr(reco_sl, ref_sl)))

        ax_ref.imshow(ref_abs, cmap="gray", vmin= 0, vmax = 1)
        ax_reco.imshow(reco_abs, cmap="gray", vmin= 0, vmax = 1)

        ax_diff = axes[get_reco_index(i)]
        if plot_diff:
            ax_diff = axes[get_diff_index(i)]
            ax_diff.set_title("Difference " + str(i) + "(x10)")
            ax_diff.imshow(10 * np.abs(diff), cmap="gray", vmin= 0, vmax = 1)

        ax_ref.set_xticks([])
        ax_ref.set_yticks([])

    plt.savefig(out_file, dpi=100)


# %%

if __name__ == "__main__":

    reco = cfl.readcfl(sys.argv[1])
    ref = cfl.readcfl(sys.argv[2])
    out_file = sys.argv[3]

    while (5 > len(reco.shape)):
        reco = reco[...,np.newaxis]

    while (5 > len(ref.shape)):
        ref = ref[...,np.newaxis]


    if (300 < reco.shape[0]):
        reco=reco[::-1,::-1,:,:,:]
        ref=ref[::-1,::-1,:,:,:]

    plot_difference(reco, ref, out_file)
