import sys

for line in sys.stdin:
    print ( ','.join([item if len(item.strip()) else '\n'
                    for item in line.strip().split(',')]))
