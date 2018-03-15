import sys
import toolshed as ts
from itertools import groupby
from operator import itemgetter

prevkey, blockSizes, blockStarts = None, [], []
tempdicts=[]
for d in ts.reader(sys.argv[1], header='ordered'):
    tempdicts.append(d)
sorter = itemgetter('unique_key')
grouper = itemgetter('unique_key')
for key, grp in groupby(sorted(tempdicts, key = sorter), grouper):
    grp=list(grp)
    start = grp[0]['start']
    end = grp[-1]['end']
    ranges = grp[0]['ranges'].split(",")
    score = float(grp[0]['ccr_pct'])
    blockCount = str(len(ranges))
    blockSizes = ",".join(map(str,[int(x[1]) - int(x[0]) for x in [x.split('-') for x in ranges]]))
    blockStarts = ",".join(map(str,[int(x[0])-int(start) for x in [x.split('-') for x in ranges]]))
    if score < 90: 
        color = '0,0,255'
    if score >= 90:
        color = '255,165,0'
    if score >= 95:
        color = '255,0,0'
    if score >= 99:
        color = '139,0,0'
    print "\t".join([grp[0]['chrom'], start, end, grp[0]['gene'], str(score), '.', start, end, color, blockCount, blockSizes, blockStarts])
