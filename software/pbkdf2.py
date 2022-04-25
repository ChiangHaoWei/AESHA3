import hashlib
import os

from aes_ebc import xor_bytes
import hmac

def hmac_sha_256(key: bytes, message: bytes):
    """
    Apply HMAC algorithm with SHA-256 to calculate mac value.
    """
    block_size = 64
    assert len(key) < block_size, "Length of HMAC key is too long"
    opad = [int('5c', 16)] * block_size
    ipad = [int('36', 16)] * block_size
    if (len(key)<block_size):
        key = key + bytes([0]*(block_size-len(key)))
    
    mac = hashlib.new('sha256', xor_bytes(key, ipad) + message).digest()
    mac = hashlib.new('sha256', xor_bytes(key, opad) + mac).digest()

    assert mac == hmac.new(key, message, 'sha256').digest()
    return mac


passward = "passward".encode()
salt = os.urandom(16)
key = hashlib.pbkdf2_hmac('sha256', passward, salt, 10, 32)
print(key)

def PBKDF2(passward, salt, c, dkLen):
  u = hmac_sha_256(passward, salt+bytes([0, 0, 0, 1]))
  u_i = u
  for j in range(2, c+1):
    u_i = hmac_sha_256(passward, u_i)
    u = xor_bytes(u, u_i)
  return u

print(PBKDF2(passward, salt, 10, 32))

