original=$1
fileName="${original##*/}"
fileExt=${fileName#*.}
FILE=${fileName%*.$fileExt}
SOFTWARE=$2 # link to folder where VEP is stored; also, can use BCSQ to annotate, we used version 81
if [ ! -s $DATA/${FILE}_dec.vcf ]; then
    vt decompose $original -o $DATA/${FILE}_dec.vcf -s  # need vt installed for this
fi

if [ ! -s $DATA/${FILE}_vt.vcf ]; then
    vt normalize $DATA/${FILE}_dec.vcf -o $DATA/${FILE}_vt.vcf -r $DATA/grch37.fa
fi

perl $SOFTWARE/ensembl-tools-release-81/scripts/variant_effect_predictor/variant_effect_predictor.pl -i $DATA/${FILE}_vt.vcf --cache --sift b --polyphen b --symbol --numbers --biotype --total_length --allele_number -o $DATA/${FILE}-vep-vt.vcf --vcf --fields ALLELE,Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON,PolyPhen,SIFT,Protein_position,BIOTYPE,ALLELE_NUM,cDNA_position --offline --fork 12 --force_overwrite

cat <(grep "^#" $DATA/${FILE}-vep-vt.vcf) <(grep -v "^#" $DATA/${FILE}-vep-vt.vcf | sort -k1,1 -k2,2n) | bgzip -c > $DATA/${FILE}-vep-vt.vcf.gz; tabix $DATA/${FILE}-vep-vt.vcf.gz
