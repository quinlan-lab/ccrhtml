# A map of constrained coding regions (CCRs) in the human genome.

#### If you use CCRs in any way, please cite the paper:

[Havrilla, J.M., Pedersen, B.S., Layer, R.M. & Quinlan, A.R. A map of constrained coding regions in the human genome. Nature Genetics (2018). doi:10.1038/s41588-018-0294-6](https://www.nature.com/articles/s41588-018-0294-6)

----------

#### Note that currently, all files use the hg19/GRCh37 human reference.

## [CCR Bed File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.autosomes.v2.20180420.bed.gz "CCR Bed File") | [CCR Tabix Index File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.autosomes.v2.20180420.bed.gz.tbi "CCR Tabix Index File") | [CCR BigWig File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.autosomes.v2.20180420.bw "CCR BigWig File") ##
## [X-CCR Bed File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.xchrom.v2.20180420.bed.gz "CCR Bed File") | [X-CCR Tabix Index File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.xchrom.v2.20180420.bed.gz.tbi "CCR Tabix Index File") | [X-CCR BigWig File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.xchrom.v2.20180420.bw "CCR BigWig File") ##

# [CCR Browser](https://rebrand.ly/ccrregions "CCR Browser")

So the browser is accessible at [rebrand.ly/ccrregions](https://rebrand.ly/ccrregions) (the link shown above) or the hard link at https://s3.us-east-2.amazonaws.com/ccrs/ccr.html.  You can use either link to get to the browser, and after either link you can submit a locus as a query to the browser at the end of the URL like so:
* rebrand.ly/ccrregions#chr20:62,064,356-62,079,335
* or rebrand.ly/ccrregions#20:62,064,356-62,079,335 
* or rebrand.ly/ccrregions#chr20:62064356-62079335 
* or rebrand.ly/ccrregions#20:62064356-62079335
* or rebrand.ly/ccrregions#KCNQ2 

Additionally you can do multi-locus search in the URL (or separated by spaces in the search bar of IGV) like so:
* rebrand.ly/ccrregions#chr20:62,064,356-62,079,335+ACTN1
* or rebrand.ly/ccrregions#KCNQ2+ACTN1
* or rebrand.ly/ccrregions#KCNQ2+ACTN1+ACTN2

![Browser Screenshot](images/browserscreenshot.png "Browser Screenshot")

## BED file columns
Column              | Description |
--------            | ----------- |
chrom               | Chromosome ID  
start               | Start coordinate (may be part of a multi-exon CCR)
end                 | End coordinate (may be part of a multi-exon CCR)
ccr_pct             | CCR percentile.  0 represents ExAC variants and is total non-constraint.  100 represents complete constraint, the highest constrained region in the model. 
gene                | HGNC gene name.
ranges              | The range of coordinates that represent the CCR.  For multi-exon spanning CCRs, this will be a comma-separated list of ranges.
varflag             | VARTRUE = 0th percentile CCR, and thus an ExAC variant coordinate (or several ExAC deletions merged into one CCR).  VARFALSE = Anything that is not a 0th percentile CCR. 
syn_density         | A calculation of the synonymous variant density of the CCR region.  Used variants that were SNPs and did not change amino acids or stop/start codons.  Allowed multiple alleles at same bp.
cpg                 | CpG dinucleotide density of the whole CCR region. 
cov_score           | The score of length scaled by coverage proportion at 10x for each base pair.  
resid               | Raw residual value from the linear regression model. 
resid_pctile        | Raw residual percentile, not weighted by proportion of exome represented.
unique_key          | A unique key ID for each CCR.
