from aes_ebc import bytes2matrix, matrix2bytes, shift_rows, sub_bytes, mix_col_add_key, inv_shift_rows, inv_sub_bytes, inv_mix_columns, add_round_key
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
        lambda s, k: mix_col_add_key(s, k, 0),
        lambda s, k: inv_shift_rows(s, 0),
        lambda s, k: inv_sub_bytes(s, 0),
        lambda s, k: inv_mix_columns(s, 0),
        lambda s, k: add_round_key(s, k, 0)
    ]
    names = ["shift_rows", "sub_bytes", "mix_col_add_key", "inv_shift_rows", "inv_sub_bytes", "inv_mix_columns", "add_round_key"]
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
            for j in range(16):
                input_fout.write(f"{input_state[i][j]:02x}")
            input_fout.write('\n')
            for j in range(16):
                res_fout.write(f"{output_state[i][j]:02x}")
            res_fout.write('\n')

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', help="directory path of random patterns", required=False, default="aes_patterns")
    parser.add_argument('-n', '--n_pattern', help="number of random pattern to be generated", required=False, default="10")
    args = parser.parse_args()

    try:
        n_pat = int(args.n_pattern)
    except:
        n_pat = 10
    os.makedirs(args.output, exist_ok=True)
    generate_testbench_pattern(args.output, n_pat)
        