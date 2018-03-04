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


def caffeTransform(im):
    # shape for input (data blob is N x C x H x W), set data
    in_ = np.array(im, dtype=np.float32)
    in_ = in_[:,:,::-1] # caffe use bgr 
    in_ -= np.array((104.00698793,116.66876762,122.67891434))
    in_ = in_.transpose((2,0,1))
    return in_
    

