import random
from pbkdf2 import PBKDF2
from aes_ebc import AES, hmac_sha3_256
import os


def generate_top_pattern(dir_path, pw_size=15, msg_len=1, n_pattern=20, mode=2):
  assert mode==0 or mode==1 or mode==2
  fsalt = open(os.path.join(dir_path, "input_salt.dat"), 'w')
  fpw = open(os.path.join(dir_path, "input_password.dat"), 'w')
  fmsg = open(os.path.join(dir_path, "input_msg.dat"), 'w')
  fmac = open(os.path.join(dir_path, "golden_hmac_value.dat"), 'w')
  fcipher = open(os.path.join(dir_path, "golden_cipher.dat"), 'w')
  fkey = open(os.path.join(dir_path, "golden_key.dat"), 'w')
  if mode==2:
    assert n_pattern%2 == 0
    for _ in range(n_pattern//2):
      passward = os.urandom(pw_size)
      salt = os.urandom(16)
      message = [os.urandom(16) for _ in range(msg_len)]
      keys = PBKDF2(passward, salt, 16)
      key, hmac_key = keys[16:], keys[0:16]
      assert len(key) == 16 and len(hmac_key)==16
      cipher = [AES(key).encrypt_block(m) for m in message]
      mac_value = [hmac_sha3_256(hmac_key, c) for c in cipher]
      fsalt.write(salt.hex() + '\n')
      fpw.write(passward.hex() + '\n')
      for i in range(msg_len):
        fmsg.write(message[i].hex())
        fcipher.write(cipher[i].hex())
        fmac.write(mac_value[i].hex())
      fmsg.write('\n')
      fcipher.write('\n')
      fmac.write('\n')
      fkey.write(keys.hex() + '\n')
    for _ in range(n_pattern//2):
      passward = os.urandom(pw_size)
      salt = os.urandom(16)
      message = [os.urandom(16) for _ in range(msg_len)]
      keys = PBKDF2(passward, salt, 16)
      key, hmac_key = keys[16:], keys[0:16]
      assert len(key) == 16 and len(hmac_key)==16
      cipher = [AES(key).decrypt_block(m) for m in message]
      mac_value = [hmac_sha3_256(hmac_key, c) for c in cipher]
      fsalt.write(salt.hex() + '\n')
      fpw.write(passward.hex() + '\n')
      for i in range(msg_len):
        fmsg.write(message[i].hex())
        fcipher.write(cipher[i].hex())
        fmac.write(mac_value[i].hex())
      fmsg.write('\n')
      fcipher.write('\n')
      fmac.write('\n')
      fkey.write(keys.hex() + '\n')
  else:
    for _ in range(n_pattern):
      passward = os.urandom(pw_size)
      salt = os.urandom(16)
      message = os.urandom(16)
      keys = PBKDF2(passward, salt, 16)
      key, hmac_key = keys[16:], keys[0:16]
      assert len(key) == 16 and len(hmac_key)==16
      if mode==1:
        cipher = AES(key).decrypt_block(message)
      else:
        cipher = AES(key).encrypt_block(message)
      mac_value = hmac_sha3_256(hmac_key, cipher)
      fsalt.write(salt.hex() + '\n')
      fpw.write(passward.hex() + '\n')
      fmsg.write(message.hex()+'\n')
      fmac.write(mac_value.hex()+'\n')
      fcipher.write(cipher.hex()+'\n')
      fkey.write(keys.hex() + '\n')
  fsalt.close()
  fpw.close()
  fmsg.close()
  fmac.close()
  fcipher.close()
  fkey.close()


if __name__ == "__main__":
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('-d', '--dir_path', help="path to output directory", required=False, default="../top_patterns")
  parser.add_argument('-m', '--mode', help="encrypt(0) or decrypt(1) or hybrid(2)", required=False, default=2)
  parser.add_argument('-l', '--msg_len', help="number of msg blocks", required=False, default=1)
  args = parser.parse_args()
  try:
    mode = int(args.mode)
    msg_len = int(args.msg_len)
  except:
    mode = 2
    msg_len = 1
  os.makedirs(args.dir_path, exist_ok=True)
  generate_top_pattern(args.dir_path, pw_size=15, msg_len=5, n_pattern=20, mode=mode)