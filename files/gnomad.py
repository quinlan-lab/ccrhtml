from __future__ import print_function

# from UCSC. see data/get-chain.py, pipe output to sort -k1,1 -k2,2n | uniq | bgzip -c > data/self-chains.gt90.bed.gz

SELF_CHAINS = "data/self-chains.gt90.bed.gz"

# from UCSC.  data/segmental.bed.gz

SEGDUPS = "data/segmental.bed.gz"

import itertools as it
import operator

import numpy as np
from cyvcf2 import VCF

import argparse

parser=argparse.ArgumentParser()
parser.add_argument("-x", "--variants", help="ExAC or some other such variant file (VCF.gz)") # again, -v prints a stupid doctest message
parser.set_defaults(variants = 'data/gnomad-vep-vt.vcf.gz')
#parser.add_argument("-c", "--coverage", help="Location of coverage files with {chrom} in name, or genome space in which you are interested (txt.gz)")
#parser.set_defaults(coverage = 'data/exacv2.chr{chrom}.cov.txt.gz')
args=parser.parse_args()
VCF_PATH = args.variants
#COVERAGE_PATH = args.coverage

zip = it.izip

import multiprocessing as mp
p = mp.Pool(12)

exac = VCF(VCF_PATH)
print (exac.raw_header,end='')
kcsq = exac["CSQ"]["Description"].split(":")[1].strip(' "').split("|")

#for chrom, viter in it.groupby(exac, operator.attrgetter("CHROM")):

def isfunctional(csq):
    for c in ('stop_gained', 'stop_lost', 'start_lost', 'initiator_codon', 'rare_amino_acid',
             'missense', 'protein_altering', 'frameshift', 'inframe_insertion', 'inframe_deletion'):
        if c in csq or (('splice_donor' in csq or 'splice_acceptor' in csq) and 'coding_sequence' in csq):
            return True
    return False

for v in exac:
    if not (v.FILTER is None or v.FILTER in ["PASS", "SEGDUP", "LCR"]):
        continue
    info = v.INFO
    try:
        as_filter=info['AS_FilterStatus'].split(",")[0]
        if as_filter not in ["PASS", "SEGDUP", "LCR"]:
            continue
    except KeyError:
        pass
    try:
        csqs = [dict(zip(kcsq, c.split("|"))) for c in info['CSQ'].split(",")]
    except KeyError:
        continue
    # NOTE: using max here for alternates to be conservative
    try: # gnomad doesn't have adj like exacv1
        ac = info['AC_Adj']
    except KeyError:
        ac = info['AC']
    if not isinstance(ac, (int, long)):
        ac = max(ac)
    try:
        af = ac / float(info['AN_Adj'] or 1)
    except KeyError:
        af = ac / float(info['AN'] or 1)
    for csq in (c for c in csqs if c['BIOTYPE'] == 'protein_coding'): # getting duplicate rows because of this, wastes memory and potentially compute time, could remove and replace with just if isfunctional, add to rows then move on?
        # skipping intronic
        if csq['Feature'] == '' or csq['EXON'] == '': continue #or csq['cDNA_position'] == '': continue
        if not isfunctional(csq['Consequence']): continue
        print(v,end='')
        break

