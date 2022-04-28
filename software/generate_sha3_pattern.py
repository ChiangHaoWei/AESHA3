from sha_3 import iota2, chi2 ,pai2,rho2,theta,_3Dto1D,bits_to_hex1, strround, fround, partition_in,sponge
import os
import numpy as np

import random
from aes_ebc import share_resource

def generate_sha3_testbench_pattern(dir_path,n_pattern=24):



    names = ["theta","rho","pai","chi","iota"]
    # input_state =
    

    funcs = [
        lambda s,r:theta(s),
        lambda s,r:rho2(s),
        lambda s,r:pai2(s),
        lambda s,r:chi2(s),
        lambda s,r:iota2(s,5)
    ]

    for h in range(len(names)):
        input_state1 =[np.random.randint(2,size=[5,5,64]) for _ in range(n_pattern)]
        input_state2=[_3Dto1D(input_state1[X])  for X in range(n_pattern)]
        input_state3=[bits_to_hex1(input_state2[X]) for X in range(n_pattern)]
        out=list()
        for i in range(n_pattern):
            out.append(funcs[h](input_state1[i],i))
            pass
        input_fout = open(os.path.join(dir_path, f"input_{names[h]}.dat"), 'w')
        res_fout = open(os.path.join(dir_path, f"golden_{names[h]}.dat"), 'w')
        for i in range(n_pattern):
            input_fout.write(input_state3[i])
            input_fout.write('\n')
            res_fout.write(bits_to_hex1(_3Dto1D(out[i])))
            res_fout.write('\n')
    newname=["sha_top"]
    for h in range(len(newname)): 
        in_f=open(os.path.join(dir_path, f"input_{newname[h]}.dat"), 'w')
        out_f=open(os.path.join(dir_path, f"golden_{newname[h]}.dat"), 'w')
        for i in range(2):
            a=[random.randint(0,1) for _ in range(1216)]
            b=strround(1088,a)
            b=partition_in(1088,b)
            c=sponge(b)
            in_f.write(bits_to_hex1(b[0]))
            in_f.write('\n')
            in_f.write(bits_to_hex1(b[1]))
            in_f.write('\n')
            out_f.write(bits_to_hex1(c))
            out_f.write('\n')
        

if __name__ == "__main__":
    os.makedirs("sha3_patterns", exist_ok=True)
    generate_sha3_testbench_pattern("sha3_patterns")