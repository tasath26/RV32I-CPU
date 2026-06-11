import struct
import sys

if len(sys.argv) != 3:
    print("Usage: python3 tohex.py input.bin output.hex")
    sys.exit(1)

with open(sys.argv[1], 'rb') as f:
    data = f.read()

data = data[:len(data) - (len(data) % 4)]

with open(sys.argv[2], 'w') as f:
    for i in range(0, len(data), 4):
        word = struct.unpack_from('<I', data, i)[0]
        f.write(f'{word:08x}\n')
