s_box = (
    0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
    0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
    0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
    0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
    0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
    0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
    0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
    0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
    0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
    0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
    0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
    0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
    0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
    0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
    0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
    0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16,
)

inv_s_box = (
    0x52, 0x09, 0x6A, 0xD5, 0x30, 0x36, 0xA5, 0x38, 0xBF, 0x40, 0xA3, 0x9E, 0x81, 0xF3, 0xD7, 0xFB,
    0x7C, 0xE3, 0x39, 0x82, 0x9B, 0x2F, 0xFF, 0x87, 0x34, 0x8E, 0x43, 0x44, 0xC4, 0xDE, 0xE9, 0xCB,
    0x54, 0x7B, 0x94, 0x32, 0xA6, 0xC2, 0x23, 0x3D, 0xEE, 0x4C, 0x95, 0x0B, 0x42, 0xFA, 0xC3, 0x4E,
    0x08, 0x2E, 0xA1, 0x66, 0x28, 0xD9, 0x24, 0xB2, 0x76, 0x5B, 0xA2, 0x49, 0x6D, 0x8B, 0xD1, 0x25,
    0x72, 0xF8, 0xF6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xD4, 0xA4, 0x5C, 0xCC, 0x5D, 0x65, 0xB6, 0x92,
    0x6C, 0x70, 0x48, 0x50, 0xFD, 0xED, 0xB9, 0xDA, 0x5E, 0x15, 0x46, 0x57, 0xA7, 0x8D, 0x9D, 0x84,
    0x90, 0xD8, 0xAB, 0x00, 0x8C, 0xBC, 0xD3, 0x0A, 0xF7, 0xE4, 0x58, 0x05, 0xB8, 0xB3, 0x45, 0x06,
    0xD0, 0x2C, 0x1E, 0x8F, 0xCA, 0x3F, 0x0F, 0x02, 0xC1, 0xAF, 0xBD, 0x03, 0x01, 0x13, 0x8A, 0x6B,
    0x3A, 0x91, 0x11, 0x41, 0x4F, 0x67, 0xDC, 0xEA, 0x97, 0xF2, 0xCF, 0xCE, 0xF0, 0xB4, 0xE6, 0x73,
    0x96, 0xAC, 0x74, 0x22, 0xE7, 0xAD, 0x35, 0x85, 0xE2, 0xF9, 0x37, 0xE8, 0x1C, 0x75, 0xDF, 0x6E,
    0x47, 0xF1, 0x1A, 0x71, 0x1D, 0x29, 0xC5, 0x89, 0x6F, 0xB7, 0x62, 0x0E, 0xAA, 0x18, 0xBE, 0x1B,
    0xFC, 0x56, 0x3E, 0x4B, 0xC6, 0xD2, 0x79, 0x20, 0x9A, 0xDB, 0xC0, 0xFE, 0x78, 0xCD, 0x5A, 0xF4,
    0x1F, 0xDD, 0xA8, 0x33, 0x88, 0x07, 0xC7, 0x31, 0xB1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xEC, 0x5F,
    0x60, 0x51, 0x7F, 0xA9, 0x19, 0xB5, 0x4A, 0x0D, 0x2D, 0xE5, 0x7A, 0x9F, 0x93, 0xC9, 0x9C, 0xEF,
    0xA0, 0xE0, 0x3B, 0x4D, 0xAE, 0x2A, 0xF5, 0xB0, 0xC8, 0xEB, 0xBB, 0x3C, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2B, 0x04, 0x7E, 0xBA, 0x77, 0xD6, 0x26, 0xE1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0C, 0x7D,
)

def print_aes_state(state, format):
    assert len(state) == 4 and len(state[0]) == 4, "Internal State of AES should be 4x4 matrix"
    assert format==1 or format==2 or format==3, "Only Two format"
    if format==1:
        print('-'*21)
        for i in range(4):
            print('|', end='')
            for j in range(4):
                print(f"{state[j][i]:^4x}|", end='')
            print()
            print('-'*21)
    else:
        for i in range(4):
            for j in range(4):
                print(f"{state[j][i]:02X}", end='')
        print()


def sub_bytes(s, debug=0):
    for i in range(4):
        for j in range(4):
            s[i][j] = s_box[s[i][j]]
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Byte Substitution:")
        print_aes_state(s, debug)

def inv_sub_bytes(s, debug=0):
    for i in range(4):
        for j in range(4):
            s[i][j] = inv_s_box[s[i][j]]
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Inv Byte Substitution:")
        print_aes_state(s, debug)


def shift_rows(s, debug=0):
    s[0][1], s[1][1], s[2][1], s[3][1] = s[1][1], s[2][1], s[3][1], s[0][1]
    s[0][2], s[1][2], s[2][2], s[3][2] = s[2][2], s[3][2], s[0][2], s[1][2]
    s[0][3], s[1][3], s[2][3], s[3][3] = s[3][3], s[0][3], s[1][3], s[2][3]
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Shift Rows:")
        print_aes_state(s, debug)


def inv_shift_rows(s, debug=0):
    s[0][1], s[1][1], s[2][1], s[3][1] = s[3][1], s[0][1], s[1][1], s[2][1]
    s[0][2], s[1][2], s[2][2], s[3][2] = s[2][2], s[3][2], s[0][2], s[1][2]
    s[0][3], s[1][3], s[2][3], s[3][3] = s[1][3], s[2][3], s[3][3], s[0][3]
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Inv Shift Rows:")
        print_aes_state(s, debug)

def add_round_key(s, k, debug=0):
    for i in range(4):
        for j in range(4):
            s[i][j] ^= k[i][j]
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Add Round Key:")
        print_aes_state(s, debug)


# learned from http://cs.ucsb.edu/~koc/cs178/projects/JT/aes.c
xtime = lambda a: (((a << 1) ^ 0x1B) & 0xFF) if (a & 0x80) else (a << 1)


def mix_single_column(a):
    # see Sec 4.1.2 in The Design of Rijndael
    t = a[0] ^ a[1] ^ a[2] ^ a[3]
    u = a[0]
    a[0] ^= t ^ xtime(a[0] ^ a[1])
    a[1] ^= t ^ xtime(a[1] ^ a[2])
    a[2] ^= t ^ xtime(a[2] ^ a[3])
    a[3] ^= t ^ xtime(a[3] ^ u)


def mix_columns(s, debug=0):
    for i in range(4):
        mix_single_column(s[i])
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print('Mix Column:')
        print_aes_state(s, debug)

def share_resource(s):
    """Sum up each column with XOR and store the result in bottom plane(y=0)"""
    assert len(s) == 5 and len(s[0])==5 and len(s[0][0])==64, "Size of Shared State should be 5x5x64"
    for x in range(5):
        for z in range(64):
            column_sum = 0
            for y in range(5):
                column_sum ^= s[x][y][z]
            s[x][0][z] = column_sum
    


def mix_col_add_key(s, k, debug=0):
    """Do mix columns and add round key at the same time to support resource sharing."""
    extend_matrix = []
    for i in range(4):
        row1 = [k[i][0], xtime(s[i][0]), xtime(s[i][1])^s[i][1], s[i][2], s[i][3]]
        row2 = [k[i][1], s[i][0], xtime(s[i][1]), xtime(s[i][2])^s[i][2], s[i][3]]
        row3 = [k[i][2], s[i][0], s[i][1], xtime(s[i][2]), xtime(s[i][3])^s[i][3]]
        row4 = [k[i][3], xtime(s[i][0])^s[i][0], s[i][1], s[i][2], xtime(s[i][3])]
        expand = [[1 if (x & (1<<b)) > 0 else 0 for b in range(8)] for x in row1]
        for j in range(5):
            expand[j].extend([1 if (row2[j] & (1<<b)) > 0 else 0 for b in range(8)])
            expand[j].extend([1 if (row3[j] & (1<<b)) > 0 else 0 for b in range(8)])
            expand[j].extend([1 if (row4[j] & (1<<b)) > 0 else 0 for b in range(8)])
            expand[j].extend([0]*32)
        assert len(expand)==5 and len(expand[0])==64
        extend_matrix.append(expand)
    extend_matrix.append([[0 for _ in range(64)] for _ in range(5)])
    assert len(extend_matrix)==5 and len(extend_matrix[1])==5 and len(extend_matrix[1][1])==64
    share_resource(extend_matrix)
    for i in range(4):
        for j in range(4):
            s[i][j] = 0
            for b in range(8):
                s[i][j] += (extend_matrix[i][0][j*8+b] << b)
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Shared Stage:")
        print_aes_state(s, debug)
    

def inv_mix_columns(s, debug=0):
    # see Sec 4.1.3 in The Design of Rijndael
    for i in range(4):
        u = xtime(xtime(s[i][0] ^ s[i][2]))
        v = xtime(xtime(s[i][1] ^ s[i][3]))
        s[i][0] ^= u
        s[i][1] ^= v
        s[i][2] ^= u
        s[i][3] ^= v

    zero_key = [[0 for _ in range(4)] for _ in range(4)]
    mix_col_add_key(s, zero_key, debug=0)
    if debug==3:
        print_aes_state(s, debug)
    elif debug>0:
        print("Inv Mix Columns:")
        print_aes_state(s, debug)


r_con = (
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40,
    0x80, 0x1B, 0x36, 0x6C, 0xD8, 0xAB, 0x4D, 0x9A,
    0x2F, 0x5E, 0xBC, 0x63, 0xC6, 0x97, 0x35, 0x6A,
    0xD4, 0xB3, 0x7D, 0xFA, 0xEF, 0xC5, 0x91, 0x39,
)


def bytes2matrix(text):
    """ Converts a 16-byte array into a 4x4 matrix.  """
    return [list(text[i:i+4]) for i in range(0, len(text), 4)]

def matrix2bytes(matrix):
    """ Converts a 4x4 matrix into a 16-byte array.  """
    return bytes(sum(matrix, []))

def xor_bytes(a, b):
    """ Returns a new byte array with the elements xor'ed. """
    return bytes(i^j for i, j in zip(a, b))

def pad(plaintext):
    """
    Pads the given plaintext with PKCS#7 padding to a multiple of 16 bytes.
    Note that if the plaintext size is a multiple of 16,
    a whole block will be added.
    """
    padding_len = 16 - (len(plaintext) % 16)
    padding = bytes([padding_len] * padding_len)
    return plaintext + padding

def unpad(plaintext):
    """
    Removes a PKCS#7 padding, returning the unpadded text and ensuring the
    padding was correct.
    """
    padding_len = plaintext[-1]
    assert padding_len > 0
    message, padding = plaintext[:-padding_len], plaintext[-padding_len:]
    assert all(p == padding_len for p in padding)
    return message

def split_blocks(message, block_size=16, require_padding=True):
        assert len(message) % block_size == 0 or not require_padding
        return [message[i:i+16] for i in range(0, len(message), block_size)]


class AES:
    """
    Class for AES-128 encryption with CBC mode and PKCS#7.

    This is a raw implementation of AES, without key stretching or IV
    management. Unless you need that, please use `encrypt` and `decrypt`.
    """
    rounds_by_key_size = {16: 10, 24: 12, 32: 14}
    def __init__(self, master_key, debug=0):
        """
        Initializes the object with a given key.
        """
        assert len(master_key) in AES.rounds_by_key_size
        self.n_rounds = AES.rounds_by_key_size[len(master_key)]
        self._key_matrices = self._expand_key(master_key)
        self.debug = debug

    def _expand_key(self, master_key):
        """
        Expands and returns a list of key matrices for the given master_key.
        """
        # Initialize round keys with raw key material.
        key_columns = bytes2matrix(master_key)
        iteration_size = len(master_key) // 4

        i = 1
        while len(key_columns) < (self.n_rounds + 1) * 4:
            # Copy previous word.
            word = list(key_columns[-1])

            # Perform schedule_core once every "row".
            if len(key_columns) % iteration_size == 0:
                # Circular shift.
                word.append(word.pop(0))
                # Map to S-BOX.
                word = [s_box[b] for b in word]
                # XOR with first byte of R-CON, since the others bytes of R-CON are 0.
                word[0] ^= r_con[i]
                i += 1
            elif len(master_key) == 32 and len(key_columns) % iteration_size == 4:
                # Run word through S-box in the fourth iteration when using a
                # 256-bit key.
                word = [s_box[b] for b in word]

            # XOR with equivalent word from previous iteration.
            word = xor_bytes(word, key_columns[-iteration_size])
            key_columns.append(word)

        # Group key words in 4x4 byte matrices.
        return [key_columns[4*i : 4*(i+1)] for i in range(len(key_columns) // 4)]

    def encrypt_block(self, plaintext):
        """
        Encrypts a single block of 16 byte long plaintext.
        """
        assert len(plaintext) == 16

        plain_state = bytes2matrix(plaintext)

        if self.debug>0:
            print(f"{'-'*20} Round 0 {'-'*20}")
        add_round_key(plain_state, self._key_matrices[0], debug=self.debug)

        for i in range(1, self.n_rounds):
            if self.debug>0:
                print(f"{'-'*20} Round {i} {'-'*20}")
            sub_bytes(plain_state, debug=self.debug)
            shift_rows(plain_state, debug=self.debug)
            mix_col_add_key(plain_state, self._key_matrices[i], debug=self.debug)
            # mix_columns(plain_state, debug=self.debug)
            # add_round_key(plain_state, self._key_matrices[i], debug=self.debug)
        if self.debug>0:
            print(f"{'-'*20} Round {self.n_rounds} {'-'*20}")
        sub_bytes(plain_state, debug=self.debug)
        shift_rows(plain_state, debug=self.debug)
        add_round_key(plain_state, self._key_matrices[-1], debug=self.debug)

        return matrix2bytes(plain_state)

    def decrypt_block(self, ciphertext):
        """
        Decrypts a single block of 16 byte long ciphertext.
        """
        assert len(ciphertext) == 16

        cipher_state = bytes2matrix(ciphertext)

        if self.debug>0:
            print(f"{'-'*20} Round 0 {'-'*20}")
        add_round_key(cipher_state, self._key_matrices[-1], debug=self.debug)
        inv_shift_rows(cipher_state, debug=self.debug)
        inv_sub_bytes(cipher_state, debug=self.debug)

        for i in range(self.n_rounds - 1, 0, -1):
            if self.debug>0:
                print(f"{'-'*20} Round {self.n_rounds - i} {'-'*20}")
            add_round_key(cipher_state, self._key_matrices[i], debug=self.debug)
            inv_mix_columns(cipher_state, debug=self.debug)
            
            inv_shift_rows(cipher_state, debug=self.debug)
            inv_sub_bytes(cipher_state, debug=self.debug)
        if self.debug>0:
            print(f"{'-'*20} Round {self.n_rounds} {'-'*20}")
        add_round_key(cipher_state, self._key_matrices[0], debug=self.debug)

        return matrix2bytes(cipher_state)
    
    def encrypt_ebc(self, plaintext):
        """
        Encrypts `plaintext` using EBC mode and PKCS#7 padding.
        """
        plaintext = pad(plaintext)
        blocks = []
        for plaintext_block in split_blocks(plaintext):
            block = self.encrypt_block(plaintext_block)
            blocks.append(block)
        return b''.join(blocks)
    
    def decrypt_ebc(self, ciphertext):
        """
        Decrypts `ciphertext` using CBC mode and PKCS#7 padding.
        """
        blocks = []
        for ciphertext_block in split_blocks(ciphertext):
            blocks.append(self.decrypt_block(ciphertext_block))
        return unpad(b''.join(blocks))

import os
import hashlib
from hashlib import pbkdf2_hmac
from hmac import new as new_hmac, compare_digest

AES_KEY_SIZE = 16
HMAC_KEY_SIZE = 16
IV_SIZE = 16

SALT_SIZE = 16
HMAC_SIZE = 32

def get_key_iv(password, salt, workload=100000):
    """
    Stretches the password and extracts an AES key, an HMAC key and an AES
    initialization vector.
    """
    stretched = pbkdf2_hmac('sha256', password, salt, workload, AES_KEY_SIZE + IV_SIZE + HMAC_KEY_SIZE)
    aes_key, stretched = stretched[:AES_KEY_SIZE], stretched[AES_KEY_SIZE:]
    hmac_key, stretched = stretched[:HMAC_KEY_SIZE], stretched[HMAC_KEY_SIZE:]
    iv = stretched[:IV_SIZE]
    return aes_key, hmac_key, iv

def get_key(key: bytes, salt: bytes):
    """
    Stretches original key and extracts an AES key and a HMAC key.
    """
    hash_key = hashlib.new('sha3_256', key+salt).digest()
    aes_key, hmac_key = hash_key[:AES_KEY_SIZE], hash_key[AES_KEY_SIZE:]
    return aes_key, hmac_key

def hmac_sha3_256(key: bytes, message: bytes):
    """
    Apply HMAC algorithm with SHA3-256 to calculate mac value.
    """
    block_size = 136
    assert len(key) < block_size, "Length of HMAC key is too long"
    opad = [int('5c', 16)] * block_size
    ipad = [int('36', 16)] * block_size
    if (len(key)<block_size):
        key = key + bytes([0]*(block_size-len(key)))
    
    mac = hashlib.new('sha3_256', xor_bytes(key, ipad) + message).digest()
    mac = hashlib.new('sha3_256', xor_bytes(key, opad) + mac).digest()
    return mac


def encrypt(key, plaintext, workload=100000, debug=0):
    """
    Encrypts `plaintext` with `key` using AES-128, an HMAC to verify integrity,
    and PBKDF2 to stretch the given key.

    The exact algorithm is specified in the module docstring.
    """
    if isinstance(key, str):
        key = key.encode('utf-8')
    if isinstance(plaintext, str):
        plaintext = plaintext.encode('utf-8')
    
    if debug>0:
        print(f"{'*'*20} Encrypt {'*'*20}")
        print("Plaintext:", plaintext)
        print("Key:", key)

    salt = os.urandom(SALT_SIZE)
    key, hmac_key = get_key(key, salt)
    ciphertext = AES(key, debug).encrypt_ebc(plaintext)
    hmac = hmac_sha3_256(hmac_key, salt + ciphertext)
    assert len(hmac) == HMAC_SIZE
    
    if debug>0:
        print("HMAC:", hmac)
        print("Salt:", salt)
        print("Ciphertext:", ciphertext)
        print(f"\n{'*'*50}\n")

    return hmac + salt + ciphertext



def decrypt(key, ciphertext, workload=100000, debug=0):
    """
    Decrypts `ciphertext` with `key` using AES-128, an HMAC to verify integrity,
    and PBKDF2 to stretch the given key.

    The exact algorithm is specified in the module docstring.
    """

    assert len(ciphertext) % 16 == 0, "Ciphertext must be made of full 16-byte blocks."

    assert len(ciphertext) >= 32, """
    Ciphertext must be at least 32 bytes long (16 byte salt + 16 byte block). To
    encrypt or decrypt single blocks use `AES(key).decrypt_block(ciphertext)`.
    """

    if isinstance(key, str):
        key = key.encode('utf-8')
    hmac, ciphertext = ciphertext[:HMAC_SIZE], ciphertext[HMAC_SIZE:]
    salt, ciphertext = ciphertext[:SALT_SIZE], ciphertext[SALT_SIZE:]
    
    if debug>0:
        print(f"{'*'*20} Decrypt {'*'*20}")
        print("Ciphertext:", ciphertext)
        print("Key:", key)

    key, hmac_key = get_key(key, salt)
    expected_hmac = hmac_sha3_256(hmac_key, salt + ciphertext)
    assert compare_digest(hmac, expected_hmac), 'Ciphertext corrupted or tampered.'
    plaintext = AES(key, debug).decrypt_ebc(ciphertext)
    if debug>0:
        print("HMAC:", expected_hmac)
        print("Salt:", salt)
        print("Plaintext:", plaintext)
        print(f"\n{'*'*50}\n")
    return plaintext


def benchmark():
    # key = b'P' * 16
    # message = b'M' * 16
    # aes = AES(key)
    # for i in range(30000):
    #     aes.encrypt_block(message)
    simple_test_case()

def simple_test_case():
    key = 'test key'
    message = 'test message'
    decrypt(key, encrypt(key, message, debug=2), debug=2)
    print("Test Shared Part")
    ts = [
        [156, 111, 0, 41],
        [127, 78, 5, 22],
        [5, 7, 5, 7],
        [1, 8, 16, 1]
    ]
    tk = [
        [3, 3, 3, 3],
        [127, 127, 127, 127],
        [2, 2, 2, 2],
        [1, 1, 1, 1]
    ]
    mix_col_add_key(ts, tk, 1)
    ts = [
        [156, 111, 0, 41],
        [127, 78, 5, 22],
        [5, 7, 5, 7],
        [1, 8, 16, 1]
    ]
    tk = [
        [3, 3, 3, 3],
        [127, 127, 127, 127],
        [2, 2, 2, 2],
        [1, 1, 1, 1]
    ]
    mix_columns(ts, 0)
    add_round_key(ts, tk, 1)



            

        

if __name__ == "__main__":
    import sys
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-df', '--debug_format', help="format of debug mode", default=0, required=False)
    parser.add_argument('-e', '--encrypt', help="message to be encrypted", required=False, default="")
    parser.add_argument('-k', '--key', help="key for hmac and aes", required=False, default="test key")
    args = parser.parse_args()
    try:
        debug_format = int(args.debug_format)
    except:
        debug_format = 0
    if args.encrypt != "":
        decrypt(args.key, encrypt(args.key, args.encrypt, debug=debug_format), debug=debug_format)
    else:
        simple_test_case()


    # write = lambda b: sys.stdout.buffer.write(b)
    # read = lambda: sys.stdin.buffer.read()

    # if len(sys.argv) < 2:
    #     print('Usage: ./aes.py encrypt "key" "message"')
    #     print('Running tests...')
    #     from test_aes import *
    #     run()
    # elif len(sys.argv) == 2 and sys.argv[1] == 'benchmark':
    #     benchmark()
    #     exit()
    # elif len(sys.argv) == 3:
    #     text = read()
    # elif len(sys.argv) > 3:
    #     text = ' '.join(sys.argv[2:])
    # if 'encrypt'.startswith(sys.argv[1]):
    #     write(encrypt(sys.argv[2], text))
    # elif 'decrypt'.startswith(sys.argv[1]):
    #     write(decrypt(sys.argv[2], text))
    # else:
    #     print('Expected command "encrypt" or "decrypt" in first argument.')
    
    
