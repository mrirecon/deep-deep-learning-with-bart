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

def calc_ssim(reco, ref, K1=0.01, K2=0.03):

    import skimage.metrics
    L = np.max(np.abs(ref))
    return skimage.metrics.structural_similarity(np.abs(reco), np.abs(ref), win_size=7, data_range=L, K1=K1, K2=K2, use_sample_covariance=True)

def plot(outfile):

    ref = cfl.readcfl(os.environ['REPO'] + "/00_data/01_example_data/01_vn_data/ref")[::-1,::-1][:,24:-24]
    out_bart = cfl.readcfl("reco_bart")[::-1,::-1][:,24:-24]
    out_tf = cfl.readcfl("reco_tf")[::-1,::-1][:,24:-24]
    out_pics = cfl.readcfl("reco_pics")[::-1,::-1][:,24:-24]
    out_adjoint = cfl.readcfl("reco_adjoint")[::-1,::-1][:,24:-24]
    
    bart_ssim = cfl.readcfl("measures/bart_ssim").real.squeeze()
    tf_ssim = cfl.readcfl("measures/tf_ssim").real.squeeze()
    pics_ssim = cfl.readcfl("measures/pics_ssim").real.squeeze()

    bart_psnr = cfl.readcfl("measures/bart_psnr").real.squeeze()
    tf_psnr = cfl.readcfl("measures/tf_psnr").real.squeeze()
    pics_psnr = cfl.readcfl("measures/pics_psnr").real.squeeze()

    fig, axes = plt.subplots(2, 5, constrained_layout=True, sharex='col', figsize=(width, 1.04 * width * ref.shape[0]/ref.shape[1] * 2 / 5))

    for i in range(4):
        axes[0][i].set_axis_off()
        axes[1][i].set_axis_off()


    scale = 0.7 * max(np.max(np.abs(ref)), np.max(np.abs(out_tf)), np.max(np.abs(out_bart)))

    axes[0,0].imshow(np.abs(ref), vmin = 0, vmax=scale, cmap="gray")
    axes[0,0].set_title("Reference + Adjoint")
    axes[0,1].imshow(np.abs(out_pics), vmin = 0, vmax=scale, cmap="gray")
    axes[0,1].set_title("$\ell_1$-Wavelet PICS")
    axes[0,2].imshow(np.abs(out_tf), vmin = 0, vmax=scale, cmap="gray")
    axes[0,2].set_title("VarNet (TensorFlow)")
    axes[0,3].imshow(np.abs(out_bart), vmin = 0, vmax=scale, cmap="gray")
    axes[0,3].set_title("VarNet (BART)")

    axes[1,0].imshow(np.abs(out_adjoint), vmin = 0, vmax=scale, cmap="gray")
    #axes[1,0].set_title("Adjoint")

    axes[1,1].imshow(np.abs(out_pics - ref), vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_pics, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(np.abs(np.abs(out_pics) -np.abs(ref))**2))
    #axes[1,1].set_title("PSNR={:.1f}; SSIM={:.2f}".format(psnr, ssim))
    axes[0,1].text(0, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)


    axes[1,2].imshow(np.abs(out_tf- ref), vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_tf, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(np.abs(np.abs(out_tf) - np.abs(ref))**2))
    #axes[1,2].set_title("PSNR={:.1f}; SSIM={:.2f}".format(psnr, ssim))
    axes[0,2].text(0, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)


    axes[1,3].imshow(np.abs(out_bart-ref), vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_bart, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(np.abs(np.abs(out_bart) -np.abs(ref))**2))
    #axes[1,3].set_title("PSNR={:.1f}; SSIM={:.2f}".format(psnr, ssim))
    axes[0,3].text(0, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)

    axes[0][4].boxplot([pics_ssim, tf_ssim, bart_ssim])
    axes[1][4].boxplot([pics_psnr, tf_psnr, bart_psnr])

    axes[0][4].set_ylim([0.5,1.])
    axes[0][4].set_title("Metrics")
    axes[0][4].set_xticks([1, 2, 3])
    axes[0][4].set_xticklabels(["PICS", "TensorFlow", "BART"])
    axes[0][4].set_ylabel("SSIM")

    axes[1][4].set_ylim([18, 42])
    axes[1][4].set_ylabel("PSNR [dB]")
    axes[1][4].set_xticks([1, 2, 3])
    axes[1][4].set_xticklabels(["PICS", "TensorFlow", "BART"])
    for tick in axes[1][4].xaxis.get_major_ticks():
        tick.label.set_position((0,0.12))

    axes[1,1].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,2].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,3].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')

    plt.savefig(outfile, dpi=600)
    plt.close()

if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)