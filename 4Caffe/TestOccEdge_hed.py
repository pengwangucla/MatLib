#!/home/peng/anaconda/bin/python

"""
Created on Mon Oct 19 13:14:33 2015

@author: peng
"""
import sys

if globals().has_key('init_modules'):
    for m in [x for x in sys.modules.keys() if x not in init_modules]:
        del(sys.modules[m]) 
else:
    init_modules = sys.modules.keys()
    
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab
import matplotlib.cm as cm

import numpy as np 
import scipy.misc as scm
from PIL import Image
import scipy.io as sio

import os
edge_method = 'parsenet_deeplab' 
#edge_method = 'parsenet_deeplab_ori'
#edge_method = 'parsenet_deeplab_cls_ori'

if edge_method in ['hed', 'hed_ori', 'hed_ori_bsds']:
    caffe_root = '../extern/hed/'
    model_root = '../extern/hed/examples/hed_occ/'
elif edge_method == 'deeplab': 
    caffe_root = '../extern/DeepLab/deeplab/'  
    model_root = caffe_root+'/exper/pascal-occ/'
elif edge_method in ['parsenet', 'parsenet_ori']:
    caffe_root = '../extern/parsenet/caffe-fcn/'  
    model_root = caffe_root+'/examples/parsenet_occ/' 
elif edge_method in ['parsenet_deeplab', 'parsenet_deeplab_ori', 'parsenet_deeplab_cls_ori']:
    caffe_root = '../extern/parsenet/caffe-fcn/'  
    model_root = caffe_root+'/examples/deeplab_occ/'
elif edge_method == 'hed_wcls':    
    caffe_root = '../extern/parsenet/caffe-fcn/'  
    model_root = caffe_root+'/examples/hed_wcls/'    

# Make sure that caffe is on the python path:
sys.path.insert(0, caffe_root + 'python')

import caffe

from _init_module import caffeTransform

# %matplotlib inline
data_root = '../Data/VOC/VOCdevkit/VOC2012/'

#Visualization
def plot_single_scale(scale_lst, size):
    pylab.rcParams['figure.figsize'] = size, size/2
    
    plt.figure()
    for i in range(0, len(scale_lst)):
        s=plt.subplot(1,5,i+1)
        plt.imshow(1-scale_lst[i], cmap = cm.Greys_r)
        s.set_xticklabels([])
        s.set_yticklabels([])
        s.yaxis.set_ticks_position('none')
        s.xaxis.set_ticks_position('none')
    plt.tight_layout()
    
    
def edge_detect_hed(im, net):
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    resedge = {}
    resedge['edgemap'] = net.blobs['sigmoid-fuse'].data[0][0,:,:]
    resedge['occmap'] = net.blobs['upscore-fuse-occ'].data[0][0,:,:]
    # save the response of each layer 
    # for edge map 
    for iedge in range(1,6):
        name_type = 'sigmoid-dsn'+'{}'.format(iedge); 
        name_save = 'edge'+'{}'.format(iedge)
        resedge[name_save] = net.blobs[name_type].data[0][0,:,:]
    for iedge in range(3,6):
        name_save = 'theta'+'{}'.format(iedge)
        name_type = 'upscore-dsn'+'{}'.format(iedge)+'-occ'
        resedge[name_save] = net.blobs[name_type].data[0][0,:,:]
    return resedge        
        
def edge_hed(in_, net, sideout=0, append='', para={'scales':1.0}):
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    resedge = {}
    mapname='edgemap'+append
    resedge[mapname] = net.blobs['sigmoid-fuse'].data[0][0,:,:]
    # save the response of each layer 
    # for edge map 
    h_,w_ =  resedge[mapname].shape
    edge_all = np.zeros((h_,w_))
    for iedge in range(1,6):
        name_type = 'sigmoid-dsn'+'{}'.format(iedge); 
        edge_all = edge_all + net.blobs[name_type].data[0][0,:,:]
    resedge['edge_mean'+append] = edge_all*0.2
    return resedge
    
def edge_detect_hed_ori(im, net, net_ori, w_edge=0, ori_name='upscore-fuse-occ', para={'scales':[1.0]}):
    resedge = {}
    for scale in para['scales']:
        append = ''
        img = im;
        if scale != 1.0:
            img = scm.imresize(im, scale)
            append = '_{0:.2f}'.format(scale)
            append = append.replace(".", "")
        print append
        
        in_ = caffeTransform(img)
        #print in_.shape
        net_ori.blobs['data'].reshape(1, *in_.shape)
        net_ori.blobs['data'].data[...] = in_
        net_ori.forward()
        if w_edge: 
            edgepred = edge_hed(in_, net, 0, append)        
            resedge['edgemap'+append] = edgepred['edgemap'+append].copy()
            
        # add back the oritation results
        res_name = 'occmap'+ append
        resedge[res_name] = net_ori.blobs[ori_name].data[0][0,:,:].copy()
        
#    for iedge in range(3,6):
#        name_save = 'theta'+'{}'.format(iedge)
#        name_type = 'upscore-dsn'+'{}'.format(iedge)+'-occ'
#        resedge[name_save] = net_ori.blobs[name_type].data[0][0,:,:]
    return resedge   
    
def edge_detect_hed_ori_e(im, net_ori, edge_res, ori_name='upscore-fuse-edge-occ'):
    in_ = caffeTransform(im)
    resedge = {}
    
    net_ori.blobs['data'].reshape(1, *in_.shape)
    net_ori.blobs['data'].data[...] = in_
#    print net_ori.blobs['data'].shape
    h,w = edge_res.shape
    edge_res = edge_res.reshape((1,h,w)) 
    net_ori.blobs['res_edge'].reshape(1, *edge_res.shape) 
    net_ori.blobs['res_edge'].data[...] = edge_res
 #   print net_ori.blobs['res_edge'].shape
    
    net_ori.forward()
    # add back the oritation results 
    resedge['occmap'] = net_ori.blobs[ori_name].data[0][0,:,:]
    
    for iedge in range(3,6):
        name_save = 'theta'+'{}'.format(iedge)
        name_type = 'upscore-dsn'+'{}'.format(iedge)+'-occ'
        resedge[name_save] = net_ori.blobs[name_type].data[0][0,:,:]
    return resedge  
    
def edge_detect_hed_fb(im, net, net_ori):
    in_ = caffeTransform(im)
    resedge = {}
    if net:
        resedge = edge_hed(in_, net)
    
    net_ori.blobs['data'].reshape(1, *in_.shape)
    net_ori.blobs['data'].data[...] = in_
    net_ori.forward()
    resedge['occmap'] = net_ori.blobs['softmax_fuse_occ'].data[0]
    return resedge
    
def edge_detect_parsenet(im, net):
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    print net.blobs['edge_score'].data[0].shape
    resedge = {}
    resedge['edgemap'] = net.blobs['edge_score'].data[0][0,:,:]
    return resedge
    
def edge_detect_parsenet_ori(im, net):
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    print net.blobs['score_occ'].data[0].shape
    resedge = {}
    resedge['occmap'] = net.blobs['score_occ'].data[0][0,:,:]
    return resedge
    
def edge_detect_hed_wcls(im, net): 
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward() 
    resedge = {} 
    resedge['clsmap'] = net.blobs['prob'].data[0]
    resedge['edgemap_hed'] = net.blobs['sigmoid-fuse'].data[0][0,:,:] 
    resedge['edgemap_sem'] = net.blobs['score_prob'].data[0][0,:,:]
    resedge['edgemap'] = net.blobs['sigmoid-joint'].data[0][0,:,:] 
    return resedge
    
def edge_detect_deeplab(im, net): 
    # joint predict edge + orientation 
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward() 
    resedge = {} 
    if 'fc_fusion_occ' in net.blobs.keys():
        resedge['occmap'] = net.blobs['fc_fusion_occ'].data[0][0,:,:]
        resedge['occmap8'] = net.blobs['upfc8_ms_occ'].data[0][0,:,:]
        resedge['occmap4'] = net.blobs['uppool4_ms_occ'].data[0][0,:,:]
        
    if 'sigmoid_fuse' in net.blobs.keys():
        resedge['edgemap'] = net.blobs['sigmoid_fuse'].data[0][0,:,:] 
    # side output 
    
    return resedge
    
def edge_detect_ori_deeplab(im, net, ori_name='fc_fusion_occ'): 
    # only predict orientation 
    resedge = {}
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    res_name = 'occmap'
    resedge[res_name] = net.blobs[ori_name].data[0][0,:,:]
    resedge['occmap4'] = net.blobs['uppool4_ms_occ'].data[0][0,:,:]
    resedge['occmap8'] = net.blobs['upfc8_ms_occ'].data[0][0,:,:]
    resedge['occmapmean'] = 0.5*resedge['occmap4']+0.5*resedge['occmap8']
    return resedge
    
def edge_detect_cls_4ori_deeplab(im, net, ori_name='prob_ori')    :
    resedge = {}
    in_ = caffeTransform(im)
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()    
    res_name = 'occmap'
    resedge[res_name] = net.blobs[ori_name].data[0][0,:,:]
    return resedge 
    
def Resize2MaxLen(in_, t_size):
    h,w,d = in_.shape
    frac_h = t_size[0]/h
    frac_w = t_size[1]/w
    frac = np.min([frac_h, frac_w])
    in_ = scm.imresize(in_, frac)
    return in_
    
#def Padding2(in_, t_size):
#    return in_
#    
#def ResizeAndPadding(in_, t_size):
#    in_ = Resize2MaxLen(in_, t_size)
#    in_, mask = Padding2(in_, t_size)
#    
#    return in_, mask
#    
#def edge_detect_deeplab(im, net):
#    in_ = caffeTransform(im)
#    in_ = ResizeAndPadding(in_, t_size)
#    
#    resedge = {}
#    
#    return resedge
    
if __name__ == '__main__':   
    
    Set = 'val'
    
    test_mod = 0
    overwrite = 1
    
    iffix = False
    print 'The method of edge inference is {}'.format(edge_method)
    
    caffe.set_mode_gpu()
    caffe.set_device(0)
    
    if edge_method == 'hed':     
        model_name = 'hed_occ_iter_100000'; 
        deploy_name = 'deploy_occ.prototxt'; 
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/hed_occ', model_name); 
        
    elif edge_method == 'hed_ori':
        model_name = 'hed_occ_iter_100000'
        deploy_name = 'deploy_occ.prototxt'
        model_name_ori = 'hed_occ_ori_c_iter_10000'
        deploy_name_ori = 'deploy_occ_ori.prototxt'
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        print "Loading net {}".format(model_name_ori) 
        net_ori = caffe.Net(model_root+deploy_name_ori, model_root+model_name_ori+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/hed_occ', model_name_ori)
                
    elif edge_method == 'hed_ori_bsds':    
        model_root = '../extern/hed/examples/bsds_occ/'
        model_name = 'hed_pretrained_bsds'
        deploy_name = 'deploy.prototxt'
        model_name_ori = 'hed_occ_ori_5_iter_50000' # orientation inference results from bsds 
        deploy_name_ori = 'deploy_occ_ori.prototxt'
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        print "Loading net {}".format(model_name_ori) 
        net_ori = caffe.Net(model_root+deploy_name_ori, model_root+model_name_ori+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/hed_occ', 'bsds'+model_name_ori)
        
    elif edge_method == 'deeplab':
        model_name = 'deep-occ-v2_iter_10000'; 
        deploy_name = 'test2_occ.prototxt';
        fixed_size = [386, 386]
        iffix = True
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        
    elif edge_method == 'parsenet':
        model_name = 'VGG_parsenet_edge_iter_10000'; 
        deploy_name = 'VGG_VOC2012ext_deploy.prototxt';
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/parsenet_occ', model_name); 
        
    elif edge_method == 'parsenet_ori':
        model_name = 'parsenet_ori_iter_14000'; 
        deploy_name = 'VGG_VOC2012ext_occ_ori_deploy.prototxt';
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/parsenet_occ', model_name); 
        
    elif edge_method == 'hed_wcls':
        model_name = 'hed_wcls_edge_iter_10000'; 
        deploy_name = 'hed_wcls_deploy.prototxt';
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/hed_wcls_occ', model_name); 
        
    elif edge_method == 'parsenet_deeplab': # predict the edges 
        model_name = 'Deep_Occ_MS_LargeFV_iter_10000' 
        # model_name = 'Deep_Occ_MS_LargeFV_neg_iter_10000'
        deploy_name = 'VGG_MS_LargeFV_deploy.prototxt'
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/parsenet_occ', model_name);    
        
    elif edge_method == 'parsenet_deeplab_ori': 
        model_name = 'Deep_Occ_MS_LargeFV_ori_iter_10000'
        # model_name = 'Deep_Occ_MS_LargeFV_neg_iter_10000'
        deploy_name = 'VGG_MS_LargeFV_deploy_ori.prototxt'
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/parsenet_occ', model_name);      
    
    elif edge_method == 'parsenet_deeplab_cls_ori': 
        model_name = 'Deep_Occ_MS_LargeFV_cls_4ori_iter_30000'
        # model_name = 'Deep_Occ_MS_LargeFV_neg_iter_10000'
        deploy_name = 'VGG_MS_LargeFV_deploy_cls_4ori.prototxt'
        print "Loading net {}".format(model_name) 
        net = caffe.Net(model_root+deploy_name, model_root+model_name+'.caffemodel', caffe.TEST)
        resPath = os.path.join('../Results/Results_occ/parsenet_occ', model_name);      
        
    ImgPath = data_root+'JPEGImages/'    
    if not os.path.exists(resPath):
        os.makedirs(resPath)
    
    listfile = data_root+'ImageSets/Segmentation/val_2010.txt'
    with open(listfile) as f:
        test_lst = f.readlines()
           
    namelist = [x.strip() for x in test_lst]
    for ind, imgname in enumerate(namelist[0:]):
        print "Inference edge {}".format(imgname)
        # shape for input (data blob is N x C x H x W), set data 
        resfile = os.path.join(resPath, imgname+'.mat')
        if os.path.exists(resfile) and not overwrite:
            continue
        im = Image.open(ImgPath+imgname+'.jpg')
        if edge_method == 'hed': 
            resedge = edge_detect_hed(im, net)
        elif edge_method == 'hed_ori':
            para = {'scales': [0.5, 1.0, 1.5]}
            resedge = edge_detect_hed_ori(im, net, net_ori, 1, 'upscore-fuse-occ', para)
        elif edge_method == 'hed_ori_bsds':
            resedge = edge_detect_hed_ori(im, net, net_ori, 0)
        elif edge_method == 'parsenet':
            im = scm.imresize(im,3.0)
            resedge = edge_detect_parsenet(im, net)  
        elif edge_method == 'parsenet_ori':
            im = scm.imresize(im,1.5)
            resedge = edge_detect_parsenet_ori(im, net)  
        elif edge_method == 'hed_wcls':
            im = scm.imresize(im,0.75)
            # im = scm.imresize(im,(300,400))
            resedge = edge_detect_hed_wcls(im, net)  
        elif edge_method == 'parsenet_deeplab':
            resedge = edge_detect_deeplab(im,net)
            
        elif edge_method == 'parsenet_deeplab_ori':
            resedge = edge_detect_ori_deeplab(im,net)
        elif edge_method == 'parsenet_deeplab_cls_ori': 
            resedge = edge_detect_cls_4ori_deeplab(im,net)          
            
        if overwrite:
            sio.savemat(os.path.join(resPath, imgname+'.mat'), resedge)
            
        if test_mod:
            if 'edgemap' in resedge.keys():
                plot_single_scale([resedge['edgemap']], 22)
            if 'edgemap_hed' in resedge.keys():
                plot_single_scale([resedge['edgemap_hed'],resedge['edgemap_sem']],22)
#            if 'clsmap' in resedge.keys():
#                plt.figure()
#                plt.imshow(resedge['clsmap'].argmax(axis=0)) 
            if 'occmap' in resedge.keys():
                plot_single_scale([resedge['occmap']], 22)
            break
            
