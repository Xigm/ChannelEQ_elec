import numpy as numpy

def interpoladorGold(inf_re,inf_im,sup_re,sup_im,index):
    out_re = inf_re*(12-index)/12 + sup_re*index/12
    out_im = inf_im*(12-index)/12 + sup_im*index/12

    return out_re,out_im
