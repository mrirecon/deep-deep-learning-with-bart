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

    ref1 = cfl.readcfl(os.environ['REPO'] + "/00_data/01_example_data/02_vn_data_alias/cim1")[::-1,::-1]
    ref2 = cfl.readcfl(os.environ['REPO'] + "/00_data/01_example_data/02_vn_data_alias/cim2")[::-1,::-1]

    plots1 = [np.sqrt(np.sum(np.abs(ref1)*np.abs(ref1),axis=3))[:,:,0]]
    plots2 = [np.sqrt(np.sum(np.abs(ref2)*np.abs(ref2),axis=3))[:,:,0]]
    
    plots1.append(cfl.readcfl("reco_modl_1_1map")[::-1,::-1].real)
    plots2.append(cfl.readcfl("reco_modl_2_1map")[::-1,::-1].real)

    plots1.append(cfl.readcfl("reco_modl_1_2map")[::-1,::-1].real)
    plots2.append(cfl.readcfl("reco_modl_2_2map")[::-1,::-1].real)

    plots1.append(cfl.readcfl("reco_vn_1_1map")[::-1,::-1].real)
    plots2.append(cfl.readcfl("reco_vn_2_1map")[::-1,::-1].real)

    plots1.append(cfl.readcfl("reco_vn_1_2map")[::-1,::-1].real)
    plots2.append(cfl.readcfl("reco_vn_2_2map")[::-1,::-1].real)

    for i in range(5):
        plots1[i] = np.abs(plots1[i])
        plots2[i] = np.abs(plots2[i])

    fig, axes = plt.subplots(2, 6, constrained_layout=True, sharex='col', figsize=(width, 1.05 * width * plots1[0].shape[0]/plots1[0].shape[1] * 2 / 6))

    for i in range(5):
        axes[0][i].set_axis_off()
        axes[1][i].set_axis_off()


    scale1 = 0.7 * np.max(plots1[0])
    scale2 = 0.7 * np.max(plots2[0])

    titles=["Reference", "MoDL (1 Map)", "MoDL (2 Maps)", "VarNet (1 Map)", "VarNet (2 Maps)"]

    for i in range(5):
        axes[0,i].imshow(plots1[i], vmin = 0, vmax=scale1, cmap="gray")
        axes[1,i].imshow(plots2[i], vmin = 0, vmax=scale2, cmap="gray")
        axes[0,i].set_title(titles[i])
    
    for i in range(1,5):
        ssim=calc_ssim(plots1[i], plots1[0])
        psnr=10*np.log10(np.max(np.abs(plots1[0]))**2/np.mean(np.abs(np.abs(plots1[i]) -np.abs(plots1[0]))**2))
        axes[0,i].text(0, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)
    
        ssim=calc_ssim(plots2[i], plots2[0])
        psnr=10*np.log10(np.max(np.abs(plots2[0]))**2/np.mean(np.abs(np.abs(plots2[i]) -np.abs(plots2[0]))**2))
        axes[1,i].text(0, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)


    labels=["M1", "M2", "V1", "V2"]
    prefix=["modl_1map", "modl_2map", "vn_1map", "vn_2map"]
    
    meas_ssim=[]
    for i in range(len(prefix)):
        meas_ssim.append(cfl.readcfl("measures/"+prefix[i]+"_ssim").real.squeeze())
    
    meas_psnr=[]
    for i in range(len(prefix)):
        meas_psnr.append(cfl.readcfl("measures/"+prefix[i]+"_psnr").real.squeeze())

    axes[0][5].set_axis_on()
    axes[1][5].set_axis_on()

    axes[0][5].boxplot(meas_ssim)
    axes[1][5].boxplot(meas_psnr)

    axes[0][5].set_ylim([0.725,0.975])
    axes[0][5].set_title("Metrics")
    axes[0][5].set_xticks([1, 2, 3, 4])
    axes[0][5].set_xticklabels(labels)#, rotation=30, ha='right')
    axes[0][5].set_ylabel("SSIM")
    for tick in axes[0][5].xaxis.get_major_ticks():
        tick.label.set_position((0,0.15))

    axes[1][5].set_ylim([27, 39])
    axes[1][5].set_ylabel("PSNR [dB]")
    axes[1][5].set_xticks([1, 2, 3, 4])
    axes[1][5].set_xticklabels(labels, va="center")
    for tick in axes[1][5].xaxis.get_major_ticks():
        tick.label.set_position((0,0.1))


    plt.savefig(outfile, dpi=600)
    plt.close()

if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)