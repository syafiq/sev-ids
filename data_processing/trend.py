import re
import csv

def read_bw(f):
    lines = []
    for a in f:
        if a.startswith("Starting"):
            lines.append(a.rstrip())
        elif ("Mbits/sec" in a):
            lines.append(a.strip())
    return lines

snp1 = read_bw(open("../generator/vanilla.log", "r").readlines())

for a in range(0, len(snp1)):
    print(snp1[a])
