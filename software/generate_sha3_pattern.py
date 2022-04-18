from sha_3 import iota2, chi2 ,pai2,rho2,theta,_3Dto1D,bits_to_hex1
import os
import numpy as np

def generate_sha3_testbench_pattern(dir_path,n_pattern=20):



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

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', help="directory path of random patterns", required=False, default="sha3_patterns")
    parser.add_argument('-n', '--n_pattern', help="number of random pattern to be generated", required=False, default="20")
    args = parser.parse_args()

    try:
        n_pat = int(args.n_pattern)
    except:
        n_pat = 20

    os.makedirs(args.output, exist_ok=True)
    generate_sha3_testbench_pattern(args.output, n_pat)