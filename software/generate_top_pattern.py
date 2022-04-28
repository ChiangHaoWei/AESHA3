import random
from pbkdf2 import PBKDF2
from aes_ebc import AES, hmac_sha3_256
import os


def generate_top_pattern(dir_path, n_pattern=20):

  fsaltkey = open(os.path.join(dir_path, "input_salt_key.dat"), 'w')
  fmsg = open(os.path.join(dir_path, "input_msg.dat"), 'w')
  fmac = open(os.path.join(dir_path, "golden_hmac_value.dat"), 'w')
  fcipher = open(os.path.join(dir_path, "golden_cipher.dat"), 'w')
  for _ in range(n_pattern):
    passward = os.urandom(15)
    salt = os.urandom(16)
    message = os.urandom(16)
    keys = PBKDF2(passward, salt, 15)
    key, hmac_key = keys[8:], keys[0:8]
    cipher = AES(key).encrypt_block(message)
    mac_value = hmac_sha3_256(hmac_key, salt+cipher)

    fsaltkey.write((salt+passward).hex() + '\n')
    fmsg.write(message.hex()+'\n')
    fmac.write(mac_value.hex()+'\n')
    fcipher.write(cipher.hex()+'\n')
  fsaltkey.close()
  fmsg.close()
  fmac.close()
  fcipher.close()


if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('-d', '--dir_path', help="path to output directory", required=False, default="../top_patterns")
  args = parser.parse_args()
  os.makedirs(args.dir_path, exist_ok=True)
  generate_top_pattern(args.dir_path, 20)