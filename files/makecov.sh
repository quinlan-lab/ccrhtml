if [ ! -d coverage ]; then
    for chrom in {1..22} X Y; do
        mkdir -p coverage
        wget -P coverage https://storage.googleapis.com/gnomad-public/release/2.0.1/coverage/exomes/gnomad.exomes.r2.0.1.chr$chrom.coverage.txt.gz
    done
fi
for i in coverage/gnomad.exomes.r2*.gz; do 
    zcat $i | sed '1d' | cut -f 1,2,7 | awk '{print $1"\t"$2-1"\t"$2"\t"$3}' | sed 's/^/chr/g' >> gnomad-coverage.bedGraph
done
bedGraphToBigWig gnomad-coverage.bedGraph hg19.chrom.sizes gnomad-coverage.bw
