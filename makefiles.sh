ver=v1
date=20171112
#ccrs.v1.20171112.bed
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
if [ ! -s gnomadbased-ccrs.$ver.$date.bed.gz ]; then
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.$ver.$date.bed.gz # ccrs in final version from pipeline
    wget https://s3.us-east-2.amazonaws.com/ccrs/ccrs/gnomadbased-ccrs.$ver.$date.bed.gz.tbi
fi

# build ccr track and files
zcat < gnomadbased-ccrs.$ver.$date.bed.gz | sort -k14,14nr | awk 'BEGIN{key=""; val=0} {{if (key !=$4 $7) val+=1} print $0 "\t" val; key=$4 $7}' | cut -f -4,7-8,10- | sort -k1,1 -k2,2n | cat <(printf "chrom\tstart\tend\tgene\tranges\tvarflag\tcpg\tcov_score\tresid\tresid_pctile\tccr_pct\tunique_key\n") - | bgzip -c > ccrs.$ver.$date.bed.gz
zcat < ccrs.$ver.$date.bed.gz | sed '1d' | sed 's/^/chr/g' | awk '{print $1,$2,$3,$11}' OFS="\t" | bedtools merge -d -1 -c 4 -o mean > ccrs.$ver.$date.bedGraph
bgzip -c ccrs.$ver.$date.bedGraph > ccrs.$ver.$date.bedGraph.gz; tabix -b 2 -e 3 ccrs.$ver.$date.bedGraph.gz
bedGraphToBigWig ccrs.$ver.$date.bedGraph hg19.chrom.sizes ccrs.$ver.$date.bw

# create BED12 of CCRs:
python bed12.py ccrs.bed.gz | bgzip -c > ccrs.bed12.bed.gz; tabix -p bed ccrs.bed12.bed.gz -f

# grab and make self-chain and segdup tracks
zcat < genomicSuperDups.txt.gz | cut -f 2-4 | sort -k1,1 -k2,2n | bgzip -c > hgsegmental.bed.gz; tabix hgsegmental.bed.gz
python get-chain.py | sort -k1,1 -k2,2n | bgzip -c > self-chains.id90.bed.gz; tabix self-chains.id90.bed.gz

# add and make pfam file
zcat < ucscGenePfam.txt.gz | cut -f 2- | bgzip -c > pfams.bed12.bed.gz; tabix pfams.bed12.bed.gz
