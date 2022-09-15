#!/usr/bin/env python3

#%%
import h5py as h5
import numpy as np

import os
import cfl
import numpy as np

path=os.environ['DATA_DIR'] + "/03_modl_data/"
os.makedirs(path, exist_ok=True)

#%%
np.random.seed(seed=123)

datasets = []
with h5.File(os.environ['DATA_PATH_MODL_BRAIN']) as f:

    datasets.append({   "name":"train",
                        "ref":f["trnOrg"][:],
                        "col":f["trnCsm"][:],
                        "pat":f["trnMask"][:]
                        })

    datasets.append({   "name":"eval",
                        "ref":f["tstOrg"][:],
                        "col":f["tstCsm"][:],
                        "pat":f["tstMask"][:]
                        })

    datasets.append({   "name":"valid",
                        "ref":f["tstOrg"][50:130:8],
                        "col":f["tstCsm"][50:130:8],
                        "pat":f["tstMask"][50:130:8]
                        })

for dataset in datasets:
    dataset["col"] = dataset["col"].transpose([2, 3, 1, 0])
    dataset["pat"] = dataset["pat"].transpose([1, 2, 0])
    dataset["ref"] = dataset["ref"].transpose([1, 2, 0])
    dataset["pat"] = np.fft.fftshift(dataset["pat"],[0, 1])

    dims_ksp = [dataset["col"].shape[0], dataset["col"].shape[1], 1, dataset["col"].shape[2], dataset["col"].shape[3]]
    dims_img = [dataset["ref"].shape[0], dataset["ref"].shape[1], 1, 1, dataset["ref"].shape[2]]

    dataset["pat"] = np.reshape(dataset["pat"], dims_img)
    dataset["ref"] = np.reshape(dataset["ref"], dims_img)
    dataset["col"] = np.reshape(dataset["col"], dims_ksp)

    def move_batchdim(x):

        new_shape = []
        for i in range(16):
            if i < len(x.shape) - 1:
                new_shape.append(x.shape[i])
            else:
                new_shape.append(1)
        new_shape[-1] = x.shape[-1]

        return x.reshape(new_shape)

    os.makedirs(path+"/"+dataset["name"], exist_ok=True)

    cfl.writecfl(path+"/"+dataset["name"]+"/ref", move_batchdim(dataset["ref"]))
    cfl.writecfl(path+"/"+dataset["name"]+"/pat", move_batchdim(dataset["pat"]))
    cfl.writecfl(path+"/"+dataset["name"]+"/col", move_batchdim(dataset["col"]))
