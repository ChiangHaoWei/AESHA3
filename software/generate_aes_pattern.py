from aes_ebc import AES, bytes2matrix, matrix2bytes, shift_rows, sub_bytes, mix_col_add_key, inv_shift_rows, inv_sub_bytes, inv_mix_columns, add_round_key, mix_columns, share_resource
import os

def generate_testbench_pattern(dir_path, n_pattern=10):
    """generate random pattern for testbench in target directory"""
    keys = [os.urandom(16) for _ in range(n_pattern)]
    key_mat = [bytes2matrix(k) for k in keys]
    with open(os.path.join(dir_path, "keys.dat"), 'w') as fout:
        for i in range(n_pattern):
            for j in range(16):
                fout.write(f"{keys[i][j]:02x}")
            fout.write('\n')
    funcs = [
        lambda s, k: shift_rows(s, 0),
        lambda s, k: sub_bytes(s, 0),
        lambda s, k: mix_columns(s, 0),
        lambda s, k: mix_col_add_key(s, k, 0),
        lambda s, k: inv_shift_rows(s, 0),
        lambda s, k: inv_sub_bytes(s, 0),
        lambda s, k: inv_mix_columns(s, 0),
        lambda s, k: add_round_key(s, k, 0),
    ]
    names = ["shift_rows", "sub_bytes","mix_columns", "mix_col_add_key", "inv_shift_rows", "inv_sub_bytes", "inv_mix_columns", "add_round_key"]
    input_state = [os.urandom(16) for _ in range(n_pattern)]
    state_mat = [bytes2matrix(x) for x in input_state]
    for h in range(len(names)):
        input_state = [os.urandom(16) for _ in range(n_pattern)]
        state_mat = [bytes2matrix(x) for x in input_state]
        for i in range(n_pattern):
            funcs[h](state_mat[i], key_mat[i])
        output_state = [matrix2bytes(x) for x in state_mat]
        input_fout = open(os.path.join(dir_path, f"input_{names[h]}.dat"), 'w')
        res_fout = open(os.path.join(dir_path, f"golden_{names[h]}.dat"), 'w')
        for i in range(n_pattern):
            for j in range(len(input_state[i])):
                input_fout.write(f"{input_state[i][j]:02x}")
            input_fout.write('\n')
            for j in range(len(output_state[i])):
                res_fout.write(f"{output_state[i][j]:02x}")
            res_fout.write('\n')
        
        input_fout.close()
        res_fout.close()
    
    input_fout = open(os.path.join(dir_path, "input_key_schedule.dat"), "w")
    res_fout = open(os.path.join(dir_path, "golden_key_schedule.dat"), "w")
    input_key = [os.urandom(16) for _ in range(n_pattern)]
    for i in range(n_pattern):
        a = AES(input_key[i])
        round_keys = a._key_matrices
        rounds = a.n_rounds
        for j in range(16):
            input_fout.write(f"{input_key[i][j]:02X}")
        input_fout.write('\n')
        for j in range(1, rounds+1):
            round_keys[j] = [bytes(x) for x in round_keys[j]]
            assert len(round_keys[j]) == 4
            for x in range(4):
                for y in range(4):
                    res_fout.write(f"{round_keys[j][x][y]:02X}") 
        res_fout.write('\n')
    input_fout.close()
    res_fout.close()

        
        
    

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', help="directory path of random patterns", required=False, default="aes_patterns")
    parser.add_argument('-n', '--n_pattern', help="number of random pattern to be generated", required=False, default="20")
    args = parser.parse_args()

    try:
        n_pat = int(args.n_pattern)
    except:
        n_pat = 20
    os.makedirs(args.output, exist_ok=True)
    generate_testbench_pattern(args.output, n_pat)
        