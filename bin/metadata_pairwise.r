#!/usr/bin/env Rscript

library(dplyr)
library(stringr)
args = commandArgs(trailingOnly=TRUE)

if(length(args) < 1){
    stop("Usage: metadataCategory.r <metadata.tsv>")
}

metadata <- args[1]
samplelist <- args[2]
samplelist <- paste(readLines(samplelist))
metadata <- read.delim(metadata)

samplelist <- gsub("_qiime_absfreq_table.qza", "", samplelist)
samplelist <- unlist(str_split(samplelist, pattern=" "))

#Exclude samples with read counts less than 1M
metadata <- metadata[metadata$sampleid %in% samplelist,]
nums <- unlist(lapply(metadata, is.numeric))
metadata <- metadata[ , !nums]
#remove blanks or NA
metadata$group <- ifelse((is.na(metadata$group) | metadata$group==""), metadata$sampleid, metadata$group)
metadata <- metadata[,c("sampleid", "group")]
#In this pipeline, multiple FASTQ files of the same sample can be merged tgoether; remove leftover duplicates from metadata
metadata <- dplyr::distinct(metadata, sampleid, .keep_all=TRUE)

#Arrange the order of the samples; for deseq2 the sample order of the design file must match the sample order of the tximport object 
metadata <- metadata[order(metadata$sample),]
rownames(metadata) <- metadata$sample
#Create grouplist and remove replicates from the list
no.replicates <- table(metadata$group)
groups <- names(no.replicates)[no.replicates > 1]
#If more than three samples and more than one group, continue with group analysis
if (length(groups) >= 1 )
{
    write.table(metadata, file="filtered_metadata.tsv", sep="\t", row.names=FALSE, quote=FALSE)
}
