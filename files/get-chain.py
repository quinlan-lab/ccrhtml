import toolshed as ts

lines = []
for line in ts.nopen("http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/chainSelf.txt.gz"): # self-chains from ucsc
    toks = line.rstrip().split("\t")
    if not toks[2].startswith('chr'): continue
    if not toks[6].startswith('chr'): continue

    score = toks[12]
    if float(score) < 90: continue


    a = [toks[2], int(toks[4]), int(toks[5])]
    b = [toks[6], int(toks[9]), int(toks[10])]
    #a.extend((score, ("%s:%s-%s" % tuple(b[:3]))))
    #b.extend((score, ("%s:%s-%s" % tuple(a[:3]))))
    lines.append(a)
    lines.append(b)

lines.sort()
for l in lines:
    l[1] = str(l[1])
    l[2] = str(l[2])
    print "\t".join(l)
