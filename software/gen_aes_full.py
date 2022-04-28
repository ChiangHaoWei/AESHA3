from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
keys = []
inputs = []
ciphers = []
plains = []
patterns = 10
for _ in range(patterns):
    keys.append(get_random_bytes(16))
    inputs.append(get_random_bytes(16))
for i in range(patterns):
    cipher = AES.new(keys[i],AES.MODE_ECB)
    ciphers.append(cipher.encrypt(inputs[i]))
    plains.append(cipher.decrypt(inputs[i]))
data_input = open("aes_patterns/full_input.dat","w")
data_key = open("aes_patterns/full_key.dat","w")
data_plain =  open("aes_patterns/full_plain.dat","w")
data_cipher = open("aes_patterns/full_cipher.dat","w")
for i in range(patterns):
    data_input.write(inputs[i].hex()+"\n")
    data_key.write(keys[i].hex()+"\n")
    data_plain.write(plains[i].hex()+"\n")
    data_cipher.write(ciphers[i].hex()+"\n")
key = b'test key'
input = b'test message'
print(key.hex())
print(input.hex())
