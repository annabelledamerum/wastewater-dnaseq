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

cleandata <- metadata[!(is.na(metadata$group) | metadata$group ==""), ]
    
noccur <- data.frame(table(cleandata$group))
compgroups  <- noccur[noccur$Freq > 1]
metadata <- metadata %>% dplyr::filter(group %in% compgroups$Var1 )

vector <- "group"

vector <- paste(vector, collapse=",")

writeLines("group", "group_list.txt")

write.table(metadata, file="filtered_metadata.tsv", sep="\t", row.names=FALSE)
