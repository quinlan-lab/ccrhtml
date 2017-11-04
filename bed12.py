import sys
import toolshed as ts

prevkey, blockSizes, blockStarts = None, [], []
for d in ts.reader(sys.argv[1], header="ordered"):
    key = d['unique_key']
    if prevkey is None:
        start = d['start']
    elif key != prevkey:
        end = prevdict['end']
        ranges = prevdict['ranges'].split(",")
        score = float(prevdict['ccr_pct'])
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
        print "\t".join([prevdict['chrom'], start, end, prevdict['gene'], str(score), '.', start, end, color, blockCount, blockSizes, blockStarts])
        blockSizes, blockStarts = [], []
        start = d['start']
    prevdict = d; prevkey = key

end = prevdict['end']
ranges = prevdict['ranges'].split(",")
blockCount = str(len(ranges))
blockSizes = ",".join(map(str,[int(x[1]) - int(x[0]) for x in [x.split('-') for x in ranges]]))
blockStarts = ",".join(map(str,[x[0] for x in [x.split('-') for x in ranges]]))
if prevdict['ccr_pct'] > 90:
    color = '255,165,0'
if prevdict['ccr_pct'] > 95:
    color = '255,0,0'
if prevdict['ccr_pct'] > 99:
    color = '139,0,0'
print "\t".join([prevdict['chrom'], start, end, prevdict['gene'], prevdict['ccr_pct'], '.', start, start, color, blockCount, blockSizes, blockStarts])
