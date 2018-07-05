ver=v2
date=20180420
software=$1
#ccrs.autosomes.v2.20180420.bed
# must upload final gzipped CCR file to S3 before this
# ENSEMBL available at: ftp://ftp.ensembl.org/pub/release-75/gtf/homo_sapiens/Homo_sapiens.GRCh37.75.gtf.gz
# refSeq at: https://s3.amazonaws.com/igv.broadinstitute.org/annotations/hg19/genes/refGene.hg19.bed.gz
# bedGraphToBigWig at: http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig (different for Mac OSX)
if [ ! -s genomicSuperDups.txt.gz ]; then
    wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/genomicSuperDups.txt.gz # segmental duplications
fi
if [ ! -s ucscGenePfam.txt.gz ]; then
    wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/ucscGenePfam.txt.gz # pfam domains
fi
if [ ! -s gnomadbased-ccrs.autosomes.$ver.$date.bed.gz ]; then
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.autosomes.$ver.$date.bed.gz # ccrs in final version from pipeline
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.autosomes.$ver.$date.bed.gz.tbi
fi
if [ ! -s gnomadbased-ccrs.xchrom.$ver.$date.bed.gz ]; then
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.xchrom.$ver.$date.bed.gz # ccrs in final version from pipeline
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.xchrom.$ver.$date.bed.gz.tbi
fi

# build ccr track and files
zcat < gnomadbased-ccrs.autosomes.$ver.$date.bed.gz | sort -k14,14nr | awk 'BEGIN{key=""; val=0} {{if (key !=$4 $7) val+=1} print $0 "\t" val; key=$4 $7}' | cut -f -4,7- | awk '{printf $1 "\t" $2 "\t" $3 "\t" $(NF-1)} {for (i = 4; i <= NF-2; i++) {printf "\t" $i}} {printf "\t" $NF "\n"}' | sort -k1,1 -k2,2n | cat <(printf "#chrom\tstart\tend\tccr_pct\tgene\tranges\tvarflag\tsyn_density\tcpg\tcov_score\tresid\tresid_pctile\tunique_key\n") - | bgzip -c > ccrs.autosomes.$ver.$date.bed.gz; tabix ccrs.autosomes.$ver.$date.bed.gz
zcat < ccrs.autosomes.$ver.$date.bed.gz | sed '1d' | sed 's/^/chr/g' | awk '{print $1,$2,$3,$4}' OFS="\t" | bedtools merge -d -1 -c 4 -o mean > ccrs.autosomes.$ver.$date.bedGraph
bgzip -c ccrs.autosomes.$ver.$date.bedGraph > ccrs.autosomes.$ver.$date.bedGraph.gz; tabix -b 2 -e 3 ccrs.autosomes.$ver.$date.bedGraph.gz
bedGraphToBigWig ccrs.autosomes.$ver.$date.bedGraph hg19.chrom.sizes ccrs.autosomes.$ver.$date.bw

zcat < gnomadbased-ccrs.xchrom.$ver.$date.bed.gz | sort -k14,14nr | awk 'BEGIN{key=""; val=0} {{if (key !=$4 $7) val+=1} print $0 "\t" val; key=$4 $7}' | cut -f -4,7- | awk '{printf $1 "\t" $2 "\t" $3 "\t" $(NF-1)} {for (i = 4; i <= NF-2; i++) {printf "\t" $i}} {printf "\t" $NF "\n"}' | sort -k1,1 -k2,2n | cat <(printf "#chrom\tstart\tend\tccr_pct\tgene\tranges\tvarflag\tsyn_density\tcpg\tcov_score\tresid\tresid_pctile\tunique_key\n") - | bgzip -c > ccrs.xchrom.$ver.$date.bed.gz; tabix ccrs.xchrom.$ver.$date.bed.gz
zcat < ccrs.xchrom.$ver.$date.bed.gz | sed '1d' | sed 's/^/chr/g' | awk '{print $1,$2,$3,$4}' OFS="\t" | bedtools merge -d -1 -c 4 -o mean > ccrs.xchrom.$ver.$date.bedGraph
bgzip -c ccrs.xchrom.$ver.$date.bedGraph > ccrs.xchrom.$ver.$date.bedGraph.gz; tabix -b 2 -e 3 ccrs.xchrom.$ver.$date.bedGraph.gz
bedGraphToBigWig ccrs.xchrom.$ver.$date.bedGraph hg19.chrom.sizes ccrs.xchrom.$ver.$date.bw


# create BED12 of CCRs:
python bed12.py ccrs.autosomes.$ver.$date.bed.gz | sort -k1,1 -k2,2n | bgzip -c > ccrs.autosomes.$ver.$date.bed12.bed.gz; tabix -p bed ccrs.autosomes.$ver.$date.bed12.bed.gz -f
python bed12.py ccrs.xchrom.$ver.$date.bed.gz | sort -k1,1 -k2,2n | bgzip -c > ccrs.xchrom.$ver.$date.bed12.bed.gz; tabix -p bed ccrs.xchrom.$ver.$date.bed12.bed.gz -f

# grab and make self-chain and segdup tracks
zcat < genomicSuperDups.txt.gz | cut -f 2-4 | sort -k1,1 -k2,2n | bgzip -c > hgsegmental.bed.gz; tabix hgsegmental.bed.gz
python get-chain.py | sort -k1,1 -k2,2n | bgzip -c > self-chains.id90.bed.gz; tabix self-chains.id90.bed.gz

# add and make pfam file
zcat < ucscGenePfam.txt.gz | cut -f 2- | bgzip -c > pfams.bed12.bed.gz; tabix pfams.bed12.bed.gz

# add and make ClinVar pathogenic functional variant file
# note that the file clinvar-pathogenic-likely_pathogenic.20170802.vcf.gz is created by the clinvar make.sh at https://github.com/quinlan-lab/pathoscore, and annotating it with ExAC exclusions is also done by pathoscore, as well as the BCSQ annotations done by bcftools, and the filtering on review status
python vars.py -f -w clinvar-pathogenic-likely_pathogenic.20170802.vcf.gz | bgzip -c > clinvar-functional-pathogenics.vcf.gz; tabix clinvar-functional-pathogenics.vcf.gz

# add gnomAD
if [ ! -s gnomad-vep-vt.vcf.gz ]; then
    wget https://storage.googleapis.com/gnomad-public/release/2.0.1/vcf/exomes/gnomad.exomes.r2.0.1.sites.vcf.gz
    wget https://storage.googleapis.com/gnomad-public/release/2.0.1/vcf/exomes/gnomad.exomes.r2.0.1.sites.vcf.gz.tbi
    bash varmake.sh gnomad.exomes.r2.0.1.sites.vcf.gz software
fi
python gnomad.py -x gnomad-vep-vt.vcf.gz > gnomad-functional-pass.vcf
bgzip -c gnomad-functional-pass.vcf > gnomad-functional-pass.vcf.gz; tabix gnomad-functional-pass.vcf.gz

# make gnomAD coverage track
bash makecov.sh

# make GERP track
bash makegerp.sh
