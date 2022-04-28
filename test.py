
bits = []
name = "a"
for i in range(135, -1, -1):
  for j in range(8):
    bits.append(f"{name}[{i*8+7-j}]")
print(', '.join(bits))