from cyvcf2 import VCF
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-f", "--functional", help="filter on functional variants", action="store_true")
parser.add_argument("-w", "--variants", help="variant file")
args = parser.parse_args()
functional=args.functional
variants=args.variants

def isfunctional(csqs):
    for csq in csqs.split(","):
        eff = csq.strip("|").split("|", 2)[0]
        if any([c in eff for c in ('stop_gained', 'stop_lost', 'start_lost', 'initiator_codon', 'rare_amino_acid',
                     'missense', 'protein_altering', 'frameshift', 'inframe_insertion', 'inframe_deletion')]) or (('splice_donor' in eff or 'splice_acceptor' in eff) and 'coding_sequence' in eff):
            return True
    return False

vcf = VCF(variants)
print vcf.raw_header,

for v in vcf: 
    if functional:
        csq = v.INFO.get("BCSQ") or v.INFO.get("CSQ")
        if csq is None or not isfunctional(csq):
            continue
        if v.INFO.get("_exclude"):
            continue
        print(str(v).strip())
