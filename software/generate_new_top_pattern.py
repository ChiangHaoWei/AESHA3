from aes_ebc import AES
import random
import os
import hashlib

def generate_top_pattern(dir_path, n_pattern=20, mode=0):
  """
  mode=0 => aes encrypt
  mode=1 => aes decrypt
  mode=2 => sha3
  mode=3 => hybrid
  """
  sha3_msg_len = 14
  assert mode>=0 and mode <=3
  fmsg = open(os.path.join(dir_path, "input_msg.dat"), 'w')
  fgolden = open(os.path.join(dir_path, "output_golden.dat"), 'w')
  fmode = open(os.path.join(dir_path, "input_mode.dat"), 'w')
  if mode != 3:
    for _ in range(n_pattern):
      cur_mode = mode if mode <=2 else random.randint(0, 2)
      if cur_mode==0:
        key = os.urandom(16)
        msg = os.urandom(16)
        cipher = AES(key).encrypt_block(msg)
        fmsg.write(msg.hex() + key.hex() + '\n')
        fgolden.write(cipher.hex()+'\n')
        fmode.write('00'+'\n')
      elif cur_mode==1:
        key = os.urandom(16)
        cipher = os.urandom(16)
        msg = AES(key).decrypt_block(cipher)
        fmsg.write(cipher.hex() + key.hex() + '\n')
        fgolden.write(msg.hex()+'\n')
        fmode.write('01'+'\n')
      elif cur_mode==2:
        msg = os.urandom(sha3_msg_len)
        hash_value = hashlib.new('sha3_256', msg).digest()
        fmsg.write(msg.hex()+'\n')
        fgolden.write(hash_value.hex()+'\n')
        fmode.write('10'+'\n')
  else:
    for _ in range(n_pattern):
      key = os.urandom(16)
      msg = os.urandom(16)
      cipher = AES(key).encrypt_block(msg)
      fmsg.write(msg.hex() + key.hex() + '\n')
      fgolden.write(cipher.hex()+'\n')
      fmode.write('00'+'\n')
    for _ in range(n_pattern):
      key = os.urandom(16)
      cipher = os.urandom(16)
      msg = AES(key).decrypt_block(cipher)
      fmsg.write(cipher.hex() + key.hex() + '\n')
      fgolden.write(msg.hex()+'\n')
      fmode.write('01'+'\n')
    for _ in range(n_pattern):
      msg = os.urandom(32)
      hash_value = hashlib.new('sha3_256', msg).digest()
      fmsg.write(msg.hex()+'\n')
      fgolden.write(hash_value.hex()+'\n')
      fmode.write('10'+'\n')
    for _ in range(n_pattern):
      msg = os.urandom(31)
      hash_value = hashlib.new('sha3_256', msg).digest()
      fmsg.write(msg.hex()+'\n')
      fgolden.write(hash_value.hex()+'\n')
      fmode.write('10'+'\n')
    for _ in range(n_pattern):
      msg = os.urandom(20)
      hash_value = hashlib.new('sha3_256', msg).digest()
      fmsg.write(msg.hex()+'\n')
      fgolden.write(hash_value.hex()+'\n')
      fmode.write('10'+'\n')
  fmsg.close()
  fgolden.close()
  fmode.close()

if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('-d', '--dir_path', help="path to output directory", required=False, default="../new_top_patterns")
  parser.add_argument('-m', '--mode', help="encrypt(0) or decrypt(1) or sha3(1)", required=False, default=0)
  args = parser.parse_args()
  try:
    mode = int(args.mode)
  except:
    mode = 0
  os.makedirs(args.dir_path, exist_ok=True)
  generate_top_pattern(args.dir_path, 20, mode)