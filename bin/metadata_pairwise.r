#!/usr/bin/env Rscript

library(dplyr)

args = commandArgs(trailingOnly=TRUE)

if(length(args) < 1){
    stop("Usage: metadataCategory.r <metadata.tsv>")
}

metadata <- args[1]

metadata <- read.delim(metadata)

nums <- unlist(lapply(metadata, is.numeric))
metadata <- metadata[ , !nums]

#If group label absent, use sample label
metadata$group <- ifelse(is.na(metadata$group), metadata$sample, metadata$group)
metadata <- metadata[,c("sampleid", "group")]
#Arrange the order of the samples; for deseq2 the sample order of the design file must match the sample order of the tximport object 
metadata <- metadata[order(metadata$sample),]
rownames(metadata) <- metadata$sample
#Create grouplist and remove replicates from the list
no.replicates <- table(metadata$group)
groups <- names(no.replicates)[no.replicates > 1]

metadata <- metadata[metadata$group %in% groups,]

if (length(metadata$sampleid > 3) & length(groups) > 1 )
{
    write.table(metadata, file="filtered_metadata.tsv", sep="\t", row.names=FALSE, quote=FALSE)
}
