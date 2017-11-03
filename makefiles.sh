#zcat ~/analysis/essentials/gnomadbased-ccrs.bed.gz | sed 's/^/chr/g' | awk '{print $1,$2,$3,$14}' OFS="\t" | bedtools groupby -g 1,2,3 -c 4 -o mean > gnomadbased-ccrs.bedGraph
zcat ~/analysis/essentials/gnomadbased-ccrs.bed.gz | sed 's/^/chr/g' | awk '{print $1,$2,$3,$14}' OFS="\t" | bedtools merge -d -1 -c 4 -o mean > gnomadbased-ccrs.bedGraph
bgzip -c gnomadbased-ccrs.bedGraph > gnomadbased-ccrs.bedGraph.gz; tabix -b 2 -e 3 gnomadbased-ccrs.bedGraph.gz
bedGraphToBigWig gnomadbased-ccrs.bedGraph $DATA/hg19.chrom.sizes gnomadbased-ccrs.bw
