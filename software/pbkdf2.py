from genericpath import exists
import hashlib
import os

from aes_ebc import xor_bytes
import hmac

def hmac_sha3_256(key: bytes, message: bytes):
    """
    Apply HMAC algorithm with SHA-256 to calculate mac value.
    """
    block_size = 136
    assert len(key) <= block_size, "Length of HMAC key is too long"
    opad = [int('5c', 16)] * block_size
    ipad = [int('36', 16)] * block_size
    if (len(key)<block_size):
        key = key + bytes([0]*(block_size-len(key)))
    
    mac_1 = hashlib.new('sha3_256', xor_bytes(key, ipad) + message).digest()
    mac_2 = hashlib.new('sha3_256', xor_bytes(key, opad) + mac_1).digest()

    assert mac_2 == hmac.new(key, message, 'sha3_256').digest()
    return mac_1, mac_2


passward = os.urandom(15)
salt = os.urandom(16)
# key = hashlib.pbkdf2_hmac('sha256', passward, salt, 10, 32)
# print(key)

def PBKDF2(passward, salt, c, dkLen=32):
  assert dkLen <= 32, "only support output less than 32 bytes"
  u = hmac_sha3_256(passward, salt+bytes([0, 0, 0, 1]))[1]
  u_i = u
  for j in range(2, c+1):
    # print(u_i.hex())
    u_i = hmac_sha3_256(passward, u_i)[1]
    u = xor_bytes(u, u_i)
  return u

def generate_hmac_pattern(dir_path, n_pattern=20):
  os.makedirs(dir_path, exist_ok=True)
  f_key = open(os.path.join(dir_path, "hmac_key_input.dat"), 'w')
  f_mid = open(os.path.join(dir_path, "hmac_mid_out.dat"), 'w')
  f_rev_msg = open(os.path.join(dir_path, "hmac_rev_msg_input.dat"), 'w')
  f_msg = open(os.path.join(dir_path, "hmac_msg_input.dat"), 'w')
  f_golden = open(os.path.join(dir_path, "hmac_golden.dat"), 'w')
  for i in range(n_pattern):
    key = os.urandom(136)
    message = os.urandom(135)
    rev_msg = bytes()
    for b in message:
      rev_msg += bytes([int(f"{b:08b}"[::-1], 2)])
    mid, golden = hmac_sha3_256(key, message)
    f_mid.write(mid.hex()+'\n')
    f_rev_msg.write((rev_msg+bytes([97])).hex()+'\n')
    f_key.write(key.hex()+'\n')
    f_msg.write((message+bytes([97])).hex()+'\n')
    f_golden.write(golden.hex()+'\n')
  f_key.close()
  f_mid.close()
  f_rev_msg.close()
  f_msg.close()
  f_golden.close()
    

def generate_pbkdf2_pattern(dir_path, c=15, n_pattern=20):
  os.makedirs(dir_path, exist_ok=True)
  f_passward = open(os.path.join(dir_path, "pbkdf2_passward_input.dat"), 'w')
  # f_rev_pw = open(os.path.join(dir_path, "pbkdf2_pw_rev.dat"), 'w')
  f_salt = open(os.path.join(dir_path, "pbkdf2_salt_input.dat"), 'w')
  f_golden = open(os.path.join(dir_path, "pbkdf2_golden.dat"), 'w')

  for _ in range(n_pattern):
    passward = os.urandom(136)
    # rev_pw = bytes()
    # for b in passward:
    #   rev_pw += bytes([int(f"{b:08b}"[::-1], 2)])
    salt = os.urandom(16)
    golden = PBKDF2(passward, salt, 16)
    f_passward.write(passward.hex()+'\n')
    # f_rev_pw.write((rev_pw+bytes([97])).hex()+'\n')
    f_salt.write(salt.hex()+'\n')
    f_golden.write(golden.hex()+'\n')
  f_passward.close()
  # f_rev_pw.close()
  f_salt.close()
  f_golden.close()

# key = PBKDF2(passward, salt, 10, 32)
# assert len(key) == 32
# print(type(key.hex()))

if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('-d', '--dir', help="path to output directary", required=False, default="../pbkdf2_patterns")
  parser.add_argument('-n', '--n_pattern', help="number of patterns to be generated", required=False, default=20)
  parser.add_argument('-i', '--iterations', help="number of iterations in pbkdf2", required=False, default=15)
  args = parser.parse_args()

  try:
    n_pat = int(args.n_pattern)
  except:
    n_pat = 20
  try:
    c = int(args.iterations)
  except:
    c = 15
  generate_pbkdf2_pattern(args.dir, c, n_pat)
  generate_hmac_pattern("../hmac_patterns", n_pat)


