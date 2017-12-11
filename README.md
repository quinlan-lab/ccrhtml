# A map of constrained coding regions (CCRs) in the human genome.

### [Preprint](https://www.biorxiv.org/content/early/2017/11/16/220814) Havrilla, J. H., Pedersen, B.S., Layer, R.M. & Quinlan, A.R. A map of constrained coding regions in the human genome. _bioRxiv_ 220814 (2017). doi:10.1101/220814

## [CCR Bed File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.v1.20171112.bed.gz "CCR Bed File") | [CCR Tabix Index File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.v1.20171112.bed.gz.tbi "CCR Tabix Index File") | [CCR BigWig File](https://s3.us-east-2.amazonaws.com/ccrs/ccrs/ccrs.v1.20171112.bw "CCR BigWig File") ##

# [CCR Browser](https://rebrand.ly/ccrregions "CCR Browser")

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
cpg                 | CpG dinucleotide density of the whole CCR region. 
cov_score           | The score of length scaled by coverage proportion at 10x for each base pair.  
resid               | Raw residual value from the linear regression model. 
resid_pctile        | Raw residual percentile, not weighted by proportion of exome represented.
unique_key          | A unique key ID for each CCR.
