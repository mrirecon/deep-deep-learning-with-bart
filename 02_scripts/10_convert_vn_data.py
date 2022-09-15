#!/usr/bin/env python3

# Author: Moritz Blumenthal
# This script is used to convert data from the Matlab file format available at GLOBUS (https://app.globus.org/file-manager?origin_id=15c7de28-a76b-11e9-821c-02b7a92d8e58&origin_path=%2F) to the BART cfl data format

#%%
import os
import os.path

import sys
import cfl

import numpy as np
import scipy as sp
import scipy.io

def join_mat_files(outfile, srcpath, prefix, field):
    
    result=[]
    slc=1

    filename='{}/{}{}.mat'.format(srcpath, prefix, slc)
    while os.path.exists(filename):
        result.append(sp.io.loadmat(filename)[field])
        slc+=1
        filename='{}/{}{}.mat'.format(srcpath, prefix, slc)

    result = np.stack(result, axis=-1)

    shp=[1]*16
    shp[0] = result.shape[0]
    shp[1] = result.shape[1]
    shp[13] = result.shape[-1]
    if (len(result.shape) > 3):
        shp[3] = result.shape[2]
    
    cfl.writecfl(outfile, result.reshape(shp))

if __name__ == "__main__":

    src_dir = sys.argv[1]
    dst_dir = sys.argv[2]

    patients=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

    for pat in patients:
        join_mat_files(dst_dir+"/"+"ksp_"+str(pat), src_dir+"/"+str(pat), "rawdata", "rawdata")
        join_mat_files(dst_dir+"/"+"col_"+str(pat), src_dir+"/"+str(pat), "espirit", "sensitivities")