from ast import Pass
from tkinter import W
import numpy as np
import os
import sys
import random
import string

from aes_ebc import share_resource
flag=0
# sys.stdout = open('progress.txt', 'w')

def bits_to_hex2(b):
    res=""
    b=list(b)
    for i in range(int(len(b)/8)):
        a=b[i*8:(i+1)*8]
        a.reverse()
        for z in range(2):
            t=a[4*z:4*(z+1)]
            hex_it=hex(int(''.join([str(j) for j in t]),2))
            # print(''.join([str(j) for j in a]))
            hex_it=hex_it[2]
            res+=hex_it
    return res
def bits_to_hex1(b):
    res=""
    b=list(b)
    for i in range(int(len(b)/4)):
        t=b[4*i:4*(i+1)]
        hex_it=hex(int(''.join([str(j) for j in t]),2))
        # print(''.join([str(j) for j in a]))
        hex_it=hex_it[2]
        res+=hex_it
        
        
        
    return  res
# arg is string item
def tobits(s):
    result = []
    for c in s:
        bits = bin(ord(c))[2:]
        bits = '00000000'[len(bits):] + bits
        tem = list(bits)
        tem.reverse()
        result.extend([int(b) for b in tem])
    return result



# arg is tobits item and block size



def strround(r,c):
    c.append(0)
    c.append(1)
    A = c + [1]
    j=(-len(c)-2)%r
    for i in range(j):
        A += [0]
    A += [1]
    # B=[0]*len(A)
    # for i in range(int(len(A)/8)):
    #     for z in range(8):
    #         B[8*(i)+z]=A[8*(i)+(7-z)]
        

    return A



def fround(r,p):
    r=int(r)
   
    return  int(len(p)/r)

def partition_in(r,p):
    c=[]
    for i in range(fround(r,p)):
        c.append(p[(i*r):((i+1)*r)])
    return c

def _1Dto3D(A):
    A_out = np.zeros((5, 5, 64), dtype = int) # Initialize empty 5x5x64 array
    for x in range(5):
        for y in range(5):
            for z in range(64):
                A_out[x][y][z] = A[64*(5*y + x) + z]
    return A_out

def _1D_XOR(A,C):
    r=len(C)
    res=[]
    for i in range(r):
        z=C[i] ^ A[i]
        res.append(z)
    b=list(A[r:])

    res=res+A[r:]

    return res

def _3Dto1D(A):
    A_out = [0]*1600
    for x in range(5):
        for y in range(5):
            for z in range(64):
                A_out[64*(5*y+x)+z] = A[x][y][z]
    return A_out

def _64bit_reverse(A):
    A_out = np.zeros((5,5,64), dtype = int)
    for x in range(5):
        for y in range(5):
            s=list(A[x][y])
            for i in range(64):
                A_out[x][y][i]=s[63-i]
    return  A_out


def test(r,s):
    a=tobits(s)
    b=strround(r,a)
    c=partition_in(r,b)
    return c


def theta2(A_in):
    A_out = [[[0 for _ in range(64)] for _ in range(5)] for _ in range(5)]
    for i in range(5):
        for j in range(5):
            for k in range(64):
                x1 = sum([A_in[i-1][jP][k] for jP in range(5)]) % 2
                x2 = sum([A_in[((i+1) % 5)][jP][k-1] for jP in range(5)]) % 2
                s = x1 + x2 + A_in[i][j][k] % 2
                A_out[i][j][k] = s
    if(flag==0):
        print("After theta:\n",_3Dto1D(A_out))
    return A_out




def theta(A):
    A_out = A.copy()  # Initialize empty 5x5x64 array
    #A_out = [[[0 for _ in range(64)] for _ in range(5)] for _ in range(5)] #without numpy
    C=np.zeros((5,64),dtype=int)
    D=np.zeros((5,64),dtype=int)
    # for i in range(5):
    #     for k in range(64):
    #         for y in range(5):
    #             C[i][k]=(C[i][k])^(A[i][y][k])
    share_resource(A)
    for i in range(5):
        for j in range(64):
            D[i][j]=(A[(i-1)%5][0][j])^(A[(i+1)%5][0][(j-1)%64])
    for i in range(5):
        for j in range(5):
            for k in range(64):
                A_out[i][j][k]=(A_out[i][j][k])^(D[i][k])
    # print("after theta")
    # print(bits_to_hex2(_3Dto1D(A_out)))
                

    return A_out


def rho2(A):
    rhomatrix=[[0,36,3,41,18],[1,44,10,45,2],[62,6,43,15,61],[28,55,25,21,56],[27,20,39,8,14]]
    rhom = np.array(rhomatrix, dtype=int)  # Initialize empty 5x5x64 array
    A_out = np.zeros((5,5,64), dtype = int)
    for i in range(5):
        for j in range(5):
            for k in range(64):
                A_out[i][j][k] = A[i][j][k - rhom[i][j]] #  A[i][j][k − (t + 1)(t + 2)/2] so here rhom[i][j] Use lookup table to "calculate" (t + 1)(t + 2)/2
    # for z in range(8):
    #     A_out[0][0][z] = A[0][0][z]
    # x = 1
    # y = 0
    # x_tmp = x
    # for i in range(23):
    #     for z in range(8):
    #         A_out[x][y][z] = A[x][y][(z-(i+1)(i+2)/2)%8]
    #     x_tmp = x
    #     x = y
    #     y = (2*x_tmp+3*y)%5
  
    return A_out


def rho(A):
    A_out = np.zeros((5,5,64), dtype = int)
    for k in range(64):
        A_out[0][0][k]=A[0][0][k]
    x=1
    y=0
    for t in range(24):
        for k in range(64):
            A_out[x][y][k]=A[x][y][(k-int((t+1)*(t+2)/2))%64]
        x_tem=x
        x=y
        y=(2*x_tem+3*y)%5
    print("after rho")
    print(bits_to_hex2(_3Dto1D(A_out)))
    return A_out
    
def pai(A):
    A_out = np.zeros((5,5,64), dtype = int) # Initialize empty 5x5x64 array
    for i in range(5):
        for j in range(5):
            for k in range(64):
                A_out[i][j][k] = A[(i+3*j)%5][i][k]
    print("after pai")
    print(bits_to_hex2(_3Dto1D(A_out)))
    return A_out

def pai2(A_in):
    A_out = [[[0 for _ in range(64)] for _ in range(5)] for _ in range(5)]
    for i in range(5):
        for j in range(5):
            for k in range(64):
                A_out[j][(2*i + 3*j) %5][k] = A_in[i][j][k]
    return A_out

def chi2(A_in):
    A_out = [[[0 for _ in range(64)] for _ in range(5)] for _ in range(5)]
    for i in range(5):
        for j in range(5):
            for k in range(64):
                or_one = (A_in[(i + 1)%5][j][k] + 1 )% 2
                or_one_mult = or_one * (A_in[(i + 2)%5][j][k])
                A_out[i][j][k] = (A_in[i][j][k] + or_one_mult) % 2
    return A_out
def chi(A):
    A_out = np.zeros((5,5,64), dtype = int) # Initialize empty 5x5x64 array
    for i in range(5):
        for j in range(5):
            for k in range(64):
                A_out[i][j][k]=(A[i][j][k]+(((A[(i + 1)%5][j][k]  +1 )% 2)&(A[(i + 2)%5][j][k]))) % 2
    print("after chi")
    print(bits_to_hex2(_3Dto1D(A_out)))
    
    return A_out

def turn8(A):
    A_out = np.zeros((5,5,64), dtype = int)

    for i in range(5):
        for j in range(5):
            s=[0]*64
            for k in range(64):
                s[k]=A[i][j][k]
            for i2 in range(8):
                for i3 in range(8):
                   A_out[i][j][8*i2+i3]=s[8*i2+(7-i3)] 


    # print("****turn8***********")
    # print(_3Dto1D(A_out))
    return A_out




def iota(A,round):
    A_out = A.copy()
    rc = [0]*255
    w = [1,0,0,0,0,0,0,0]

    rc[0] = w[0]
    for i in range(1,255):
        w_b=[0]+w
        w_b[0]=w_b[0]^w_b[8]
        w_b[4]=w_b[4]^w_b[8]
        w_b[5]=w_b[5]^w_b[8]
        w_b[6]=w_b[6]^w_b[8]
        w=w_b[:8]
        rc[i]=w[0]

    for l in range(7):
        A_out[0][0][2**l-1]^=rc[l+7*round]
    print("after iota")
    print(bits_to_hex2(_3Dto1D(A_out)))
    return(A_out)

def iota2(A_in, round):
    # generate rc
    A_out = A_in.copy()
    w=[1,0,0,0,0,0,0,0]
    rc = [w[0]]
    for _ in range(1,168):
        w=[w[1],w[2],w[3],w[4],w[5],w[6],w[7],(w[0]+w[4]+w[5]+w[6])%2]
        rc.append(w[0])

    for l in range(7):
        A_out[0][0][2**l - 1] = ((A_out[0][0][2**l - 1] + rc[l + 7*round]) )% 2

    return A_out

def Rnd(arry_3d,ir):
    global flag
    # xd=turn8(arry_3d)
    a=theta(arry_3d)
    b=rho(a)
    c=pai(b)
    d=chi(c)
    e=iota(d,ir)
    flag=1
    return e


def kekka(A,round):
    # z=turn8(A)
    b=A
    for i in range(round):
        print("Round %d"% i)        
        A_out=Rnd(b,i)
        
        b=A_out

    return A_out


def sponge(C):
    S=[0]*1600
    for i in C:
        a=_1D_XOR(S,i)
        b=_1Dto3D(a)
        c=kekka(b,24)        # 3d type
        S=_3Dto1D(c)
       
    res=S[0:256]
    return res
        
            

def frombits(bits):
    chars = []
    for b in range(int(len(bits) / 8)):
        byte = bits[b*8:(b+1)*8]
        chars.append(chr(int(''.join([str(bit) for bit in byte]), 2)))
    return ''.join(chars)




def SHA3_256_str_to_hex(s):
    
    a=test(1088,s)
    b=sponge(a)
    res=bits_to_hex2(b)
    print("***************result*****************\n")
    return res

print(SHA3_256_str_to_hex(""))
    

def generatetwofile():
    os.makedirs("sha3_patterns")
    with open (os.path.join("sha3_patterns", "input_pattern.dat"),'w') as fi:
        with open(os.path.join("sha3_patterns", 'output_pattern.dat'),'w') as fo:
            
            for i in range(10):
                
                s=''.join(random.SystemRandom().choice(string.ascii_letters+string.digits) for _ in range(random.SystemRandom().randint(0, 136)))
                fi.write(s+'\n')
                fo.write(SHA3_256_str_to_hex(s)+'\n')
# generatetwofile()
# sys.stdout.close()
    



