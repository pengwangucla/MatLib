# -*- coding: utf-8 -*-
"""
Created on Sun Nov  1 15:51:53 2015

@author: peng
"""

import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab
import matplotlib.cm as cm
import scipy.misc as scm
from PIL import Image
import scipy.io as sio
import os
import cv2

# the size in NYU data,  using the eigen's model the predicted crop region 
pred_size_model = (640, 480)
crop_size_eigen = [22, 26, 458,  614] 
pred_size_eigen = (588, 436)

# the size in NYU data,  using the eigen's model the predicted crop region 
crop_size_nyu = np.array([44, 41, 471, 602], dtype=np.float32)
crop_size_ori = np.array([44, 41, 458, 602], dtype=np.float32) # eigen's results under the original image
crop_size_n = crop_size_ori - np.concatenate((crop_size_ori[0:2], crop_size_ori[0:2]))
crop_size_n = crop_size_n.astype(np.int)

# default camera parameters after cropping 
camera_o = np.array([325.5824, 253.7361, 518.8579, 519.4696], dtype=np.float32)
camera=camera_o.copy()
camera[0:2] -= crop_size_ori[0:2] # recenter for computing 3d points 

def caffeTransform(im):
    # shape for input (data blob is N x C x H x W), set data
    in_ = np.array(im, dtype=np.float32)
    in_ = in_[:,:,::-1] # caffe use bgr 
    in_ -= np.array((104.00698793,116.66876762,122.67891434))
    in_ = in_.transpose((2,0,1)) # change to c h w 
    return in_
    
def dumpnet2Dic(net, respath, out_name): 
    dicNet = {}
    print 'dumping a network to mat file for visualization'
    for name in net.blobs.keys():
        dicNet[name] = net.blobs[name].data[0][:,:,:] 
    sio.savemat(respath+out_name+'.mat', dicNet)
    
def caffeTransfrom_eigen(im, scale=1): 
    in_ = np.array(im, dtype=np.float32)    
    #in_ = in_[:,:,::-1]
    
    if scale is 1:
        in_ -= np.array((123.68, 116.779, 103.939)) 
    elif scale is 2: 
        images_mean = 109.31410628
        images_std = 76.18328376
        images_istd = 1.0 / images_std
        in_ -= np.array(images_mean)
        in_ *= images_istd
    in_ = in_.transpose((2,0,1))
    return in_
    
def read_textline(filename):
    with open(filename) as f:
        test_list = f.readlines()
    name_list = [x.strip() for x in test_list]
    return name_list

# crop the image in NYU v2 data 
def crop_img_v2(im, cs = [ 0,   0, 414, 561]):
    if np.ndim(im) == 2: 
        im= im[:,:,None]
    im = im[cs[0]:cs[2], cs[1]:cs[3], :]
    return np.squeeze(im)
    
def resize_multi(im, t_size):
    assert np.ndim(im) == 3 or np.ndim(im) == 4
    n_img = im.shape[0]
    if np.ndim(im) == 3:
        res = np.zeros((n_img, t_size[1], t_size[0]),dtype=np.float32); 
    else:
        res = np.zeros((n_img, t_size[1], t_size[0], im.shape[3]),dtype=np.float32);         
        
    for iimg in range(im.shape[0]):
        res[iimg] = cv2.resize(im[iimg], t_size)
    return res
    
def plot_images(img_lst, Keys=None, message='', sz = [2,5], size=22):
    
    pylab.rcParams['figure.figsize'] = size, size/2
    if not Keys: 
        Keys = img_lst.keys()
        
    plt.figure()
    for iimg, name in enumerate(Keys): 
        s=plt.subplot(sz[0],sz[1],iimg+1)
        if name.split('_')[0] in ['edge']:
            plt.imshow(1.0-img_lst[name],  cmap = cm.Greys_r) 
        elif name.split('_')[0] in ['plane']:
            plt.imshow(img_lst[name],  cmap = cm.Greys_r)             
        else: 
            plt.imshow(img_lst[name])
        s.set_xticklabels([])
        s.set_yticklabels([])
        s.set_title(name+message)
        s.yaxis.set_ticks_position('none')
        s.xaxis.set_ticks_position('none')
    plt.tight_layout()
    
def plot_grey_images(img_lst, Keys=None, inv = 0, sz = [2,5], size=22):
    
    pylab.rcParams['figure.figsize'] = size, size/2
    if not Keys: 
        Keys = img_lst.keys()
        
    plt.figure()
    for iimg, name in enumerate(Keys): 
        s=plt.subplot(sz[0],sz[1],iimg+1)
        if inv:
            plt.imshow(1.0-img_lst[name],  cmap = cm.Greys_r) 
        else:
            plt.imshow(img_lst[name],  cmap = cm.Greys_r) 
            
        s.set_xticklabels([])
        s.set_yticklabels([])
        s.set_title(name)
        s.yaxis.set_ticks_position('none')
        s.xaxis.set_ticks_position('none')
    plt.tight_layout()    