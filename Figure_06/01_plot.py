#!/usr/bin/env python3

import os
import sys
import numpy as np
import cfl

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 11})
width=9.5*7/4

def calc_ssim(reco, ref, K1=0.01, K2=0.03):

    import skimage.metrics
    L = np.max(np.abs(ref))
    return skimage.metrics.structural_similarity(np.abs(reco), np.abs(ref), win_size=7, data_range=L, K1=K1, K2=K2, use_sample_covariance=True)

def plot(outfile):

    ref = cfl.readcfl(os.environ['REPO'] + "/00_data/01_example_data/01_vn_data/ref")[::-1,::-1][:,24:-24]
    traj = np.real(cfl.readcfl(os.environ['REPO'] + "/00_data/01_example_data/01_vn_data/trj"))
    
    out_vn =        cfl.readcfl("reco_varnet")[::-1,::-1][:,24:-24]
    out_modl =      cfl.readcfl("reco_modl")[::-1,::-1][:,24:-24]
    out_modl_one =  cfl.readcfl("reco_modl_one")[::-1,::-1][:,24:-24]
    
    out_adj =      cfl.readcfl("reco_adjoint")[::-1,::-1][:,24:-24]
    out_pics =      cfl.readcfl("reco_pics")[::-1,::-1][:,24:-24]
    out_pics_l =    cfl.readcfl("reco_pics_l1")[::-1,::-1][:,24:-24]


    fig, axes = plt.subplots(2, 7, constrained_layout=True, figsize=(width, width * 1.1 * 2 / 7 * ref.shape[0]/ref.shape[1]))
    
    for ax in axes.flatten():
        ax.set_axis_off()
    
    scale = 0.7 * max(np.max(np.abs(ref)), np.max(np.abs(out_vn)), np.max(np.abs(out_modl)), np.max(np.abs(out_modl_one)))
    
    axes[0,0].imshow(np.abs(ref), vmin = 0, vmax=scale, cmap="gray")
    axes[0,0].set_title("Reference + Traj.")

    #axes[0,1].imshow(np.abs(out_adj), vmin = 0, cmap="gray")
    #axes[0,1].set_title("Adjoint (DC)")
    
    axes[1,0].plot(traj[0,:,:], traj[1,:,:], color="black")
    #axes[2,4].set_title("Trajectory")
    axes[1, 0].set_aspect('equal', adjustable='box')
    
    axes[0,1].imshow(np.abs(out_pics), vmin = 0, vmax=scale, cmap="gray")
    axes[0,1].set_title("CG-SENSE")
    axes[0,2].imshow(np.abs(out_pics_l), vmin = 0, vmax=scale, cmap="gray")
    axes[0,2].set_title("$\ell_1$-Wavelet PICS")
    
    axes[0,3].imshow(np.abs(out_modl_one), vmin = 0, vmax=scale, cmap="gray")
    axes[0,3].set_title("MoDL ($T=1$)")
    axes[0,4].imshow(np.abs(out_modl), vmin = 0, vmax=scale, cmap="gray")
    axes[0,4].set_title("MoDL ($T=5$)")
    axes[0,5].imshow(np.abs(out_vn), vmin = 0, vmax=scale, cmap="gray")
    axes[0,5].set_title("VarNet")
    
    diff=np.abs(np.abs(out_pics) - np.abs(ref))
    axes[1,1].imshow(diff, vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_pics, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(np.abs(np.abs(out_pics) -np.abs(ref))**2))
    axes[0,1].text(10, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)

    diff=np.abs(np.abs(out_pics_l) - np.abs(ref))
    axes[1,2].imshow(diff, vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_pics_l, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(diff**2))
    axes[0,2].text(10, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)
    
    diff=np.abs(np.abs(out_modl_one) - np.abs(ref))
    axes[1,3].imshow(diff, vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_modl_one, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(diff**2))
    axes[0,3].text(10, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)
    
    diff=np.abs(np.abs(out_modl) - np.abs(ref))
    axes[1,4].imshow(diff, vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_modl, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(diff**2))
    axes[0,4].text(10, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)
    
    diff=np.abs(np.abs(out_vn) - np.abs(ref))
    axes[1,5].imshow(diff, vmin = 0, vmax=.1*scale, cmap="gray")
    ssim=calc_ssim(out_vn, ref)
    psnr=10*np.log10(np.max(np.abs(ref))**2/np.mean(diff**2))
    axes[0,5].text(10, 310, "PSNR={:.1f}\nSSIM={:.2f}".format(psnr, ssim), color="white", fontsize=12)
    
    labels=["CG", "$\ell_1$-W", "M1", "M5", "VN"]
    prefix=["pics_cg", "pics_l1", "modl1", "modl2", "varnet"]
    
    meas_ssim=[]
    for i in range(len(prefix)):
        meas_ssim.append(cfl.readcfl("measures/"+prefix[i]+"_ssim").real.squeeze())
    
    meas_psnr=[]
    for i in range(len(prefix)):
        meas_psnr.append(cfl.readcfl("measures/"+prefix[i]+"_psnr").real.squeeze())

    axes[0][6].set_axis_on()
    axes[1][6].set_axis_on()

    axes[0][6].boxplot(meas_ssim)
    axes[1][6].boxplot(meas_psnr)

    axes[0][6].set_ylim([0.5,1.])
    axes[0][6].set_title("Metrics")
    axes[0][6].set_xticks([1, 2, 3, 4, 5])
    axes[0][6].set_xticklabels(labels)#, rotation=30, ha='right')
    axes[0][6].set_ylabel("SSIM")
    for tick in axes[0][6].xaxis.get_major_ticks():
        tick.label.set_position((0,0.15))

    axes[1][6].set_ylim([23, 42])
    axes[1][6].set_ylabel("PSNR [dB]")
    axes[1][6].set_xticks([1, 2, 3, 4, 5])
    axes[1][6].set_xticklabels(labels, va="center")
    for tick in axes[1][6].xaxis.get_major_ticks():
        tick.label.set_position((0,0.1))

    axes[1,1].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,2].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,3].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,4].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')
    axes[1,5].text(310, 310, "x10", color="white", fontsize=12, va='bottom', ha='right')



    plt.savefig(outfile, dpi=600)
    plt.close()


if __name__ == "__main__":

    outfile = sys.argv[1]
    plot(outfile)