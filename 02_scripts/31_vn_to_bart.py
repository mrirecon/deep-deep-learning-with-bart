import tensorflow as tf
import cfl
import numpy as np
import sys
import argparse

parser = argparse.ArgumentParser(description='convert tensorflow weights of variational network to BARTs CFL format')
parser.add_argument('version', type=str, help='must be "optox" or "icg" depending on VarNet version')
parser.add_argument('checkpoint', type=str, help='path of the checkpoint, for example logs/vnmri/mri_vn_2022-01-17--20-27-37/checkpoints/checkpoint-390')
parser.add_argument('output_name', type=str, help='output weight file')

if __name__ == "__main__":

    args = parser.parse_args()

    reader = tf.compat.v1.train.NewCheckpointReader(args.checkpoint)

    shape_from_key = reader.get_variable_to_shape_map()
    print("Found the following tensors in checkpoint:")
    print(sorted(shape_from_key.keys()))

    conv_w = np.transpose(reader.get_tensor("k1"), (4, 3, 1, 2, 0))
    shp=conv_w.shape
    conv_w = conv_w.reshape([shp[0], shp[1], shp[2], shp[3], 1, shp[4]])
    # out_channel, in_channel, X, Y, Z, Iteration
    print(conv_w.shape)

    rbf_w = np.transpose(reader.get_tensor("w1"), (1, 2, 0))
    print(rbf_w.shape)

    lambda_w = np.array(reader.get_tensor("lambda"))[:,0]
    print(lambda_w.shape)

    scale = 0.
    if args.version=="optox":
        scale = 0.4
    if args.version=="icg":
        scale = 1.0

    cfl.writemulticfl(args.output_name, [lambda_w, conv_w, scale * rbf_w])