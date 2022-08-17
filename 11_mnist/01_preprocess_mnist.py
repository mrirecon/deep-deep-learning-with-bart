# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
import struct as st
import numpy as np
import gzip
import os

import cfl

data_path=os.environ['REPO']+"/11_mnist/"

# %%

files = {   "train_images": "http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz",
            "train_labels": "http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz",
            "test_images":  "http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz",
            "test_labels":  "http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz"}

import urllib.request
for name in list(files):
    urllib.request.urlretrieve(files[name], data_path + name + '.gz')


# %%
train_imagesfile = gzip.open(data_path + 'train_images.gz','rb')
train_imagesfile.seek(0)
magic = st.unpack('>4B',train_imagesfile.read(4))
nImg = st.unpack('>I',train_imagesfile.read(4))[0] #num of images
nR = st.unpack('>I',train_imagesfile.read(4))[0] #num of rows
nC = st.unpack('>I',train_imagesfile.read(4))[0] #num of column
images_array = np.zeros((nImg,nR,nC))
nBytesTotal = nImg*nR*nC*1 #since each pixel data is 1 byte
train_images = np.asarray(st.unpack('>'+'B'*nBytesTotal,train_imagesfile.read(nBytesTotal))).reshape((nImg,nR,nC))

test_imagesfile = gzip.open(data_path + 'test_images.gz','rb')
test_imagesfile.seek(0)
magic = st.unpack('>4B',test_imagesfile.read(4))
nImg = st.unpack('>I',test_imagesfile.read(4))[0] #num of images
nR = st.unpack('>I',test_imagesfile.read(4))[0] #num of rows
nC = st.unpack('>I',test_imagesfile.read(4))[0] #num of column
images_array = np.zeros((nImg,nR,nC))
nBytesTotal = nImg*nR*nC*1 #since each pixel data is 1 byte
test_images = np.asarray(st.unpack('>'+'B'*nBytesTotal,test_imagesfile.read(nBytesTotal))).reshape((nImg,nR,nC))
test_imagesfile.close()

train_labelsfile = gzip.open(data_path + 'train_labels.gz','rb')
train_labelsfile.seek(0)
magic = st.unpack('>4B',train_labelsfile.read(4))
nImg = st.unpack('>I',train_labelsfile.read(4))[0] #num of images
images_array = np.zeros((nImg))
nBytesTotal = nImg*1 #since each pixel data is 1 byte
train_labels = np.asarray(st.unpack('>'+'B'*nBytesTotal,train_labelsfile.read(nBytesTotal))).reshape((nImg))

test_labelsfile = gzip.open(data_path + 'test_labels.gz','rb')
test_labelsfile.seek(0)
magic = st.unpack('>4B',test_labelsfile.read(4))
nImg = st.unpack('>I',test_labelsfile.read(4))[0] #num of images
images_array = np.zeros((nImg))
nBytesTotal = nImg*1 #since each pixel data is 1 byte
test_labels = np.asarray(st.unpack('>'+'B'*nBytesTotal,test_labelsfile.read(nBytesTotal))).reshape((nImg))


# %%
def hotenc(x):
    result = np.zeros((10, len(x)))
    for i in range(len(x)):
        result[x[i], i] = 1
    return result

x_train = np.transpose(train_images, (1,2,0))
x_test = np.transpose(test_images, (1,2,0))
x_train = x_train.astype(complex) / 255.
x_test = x_test.astype(complex) / 255.
y_train = hotenc(train_labels)
y_test = hotenc(test_labels)

cfl.writecfl(data_path + "train_images",x_train)
cfl.writecfl(data_path + "train_labels",y_train)
cfl.writecfl(data_path + "test_images",x_test)
cfl.writecfl(data_path + "test_labels",y_test)
