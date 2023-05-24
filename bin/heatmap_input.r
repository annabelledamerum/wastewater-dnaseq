#!/usr/bin/env Rscript

library(stringr)
library(matrixStats)
library(dplyr)
library(reshape)
library(tidyr)

args = commandArgs(trailingOnly=TRUE)

if(length(args) < 1){
  stop("Usage: heatmap_input_sort20.r <tsv> <metadata> <top_n>")
}

table <- args[1]
metadata <- args[2]
top_taxa <- as.numeric(args[3])

input <- read.csv(file = table, header=TRUE, sep="\t", check.names=FALSE, stringsAsFactors=FALSE, na.strings=c("","NA"))
grouping <- read.csv(file = metadata, header=TRUE, sep="\t",check.names=FALSE, stringsAsFactors=FALSE)
input <- tidyr::separate(input, "OTU ID", c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep = "\\|")
rownames(grouping) <- grouping[,1]
grouping <- subset(grouping, select = c(2))
names(grouping)[1] <- "group"

filter <- function(data,grouping,top_taxa) {
  data <- aggregate(.~id,data=data,FUN=sum)
  rownames(data) <- data[,1]
  data <- subset(data, select = -c(id))
  data <- round(data, digits = 3)
  dataF <-as.data.frame(t(data))
  dataF <-cbind(dataF, grouping)
  dataF <- as.data.frame(dataF%>%group_by(group)%>%summarise_all("mean"))
  rownames(dataF) <- dataF[,1]
  dataF <- subset(dataF, select = -c(group))
  dataF<-as.data.frame(t(dataF))
  dataF$ID <- row.names(dataF)
  dataF <- melt(dataF, id.vars=c("ID"))
  dataF <- as.data.frame(dataF %>% group_by(variable) %>% slice_max(order_by = value, n = top_taxa))
  dataF <- aggregate(.~ID,data=dataF,FUN=sum)
  dataF <- subset(dataF, select = -c(variable, value))
  rownames(dataF) <- dataF[,1]
  dataC <- merge(dataF, data, by=0, all=FALSE)
  rownames(dataC) <- dataC[,1]
  dataC <- subset(dataC, select = -c(ID,Row.names))
  # dataC <- (dataC-rowMeans(dataC))/(rowSds(as.matrix(dataC)))[row(dataC)]
  # dataC <- dataC[rowSums(is.na(dataC)) == 0,]
  data_rowclust <- hclust(dist(dataC))
  data_colclust <- hclust(dist(t(dataC)))
  dataC <- dataC[data_rowclust$order, data_colclust$order]
  return(dataC)
}

species <- input[,c(6,7,8:ncol(input))]
a <- colSums(!is.na(subset(species,select =c(2))))
if (a < 10) {
  species$Species <- paste(species$Genus, species$Species)
  species$Species <- str_replace(species$Species, "NA", "sp")
  species <-species[!(species$Species=="sp NA"),]
} else {
  species <-species[!(species$Species=="NA"),]
  species$Species <- paste(species$Genus, species$Species)
  species <-species[!(species$Species=="NA NA"),]
}
species <- subset(species, select = -c(Genus))
names(species)[1] <- "id"
species <- filter(data = species,grouping = grouping, top_taxa = top_taxa)
write.table(species, "Species_taxo_heatmap.csv", sep="\t", quote=FALSE)

genus <- input[,c(6,8:ncol(input))]
names(genus)[1] <- "id"
genus <- filter(data = genus,grouping = grouping, top_taxa = top_taxa)
write.table(genus, "Genus_taxo_heatmap.csv", sep="\t", quote=FALSE)

family <- input[,c(5,8:ncol(input))]
names(family)[1] <- "id"
family <- filter(data = family,grouping = grouping, top_taxa = top_taxa)
write.table(family, "Family_taxo_heatmap.csv", sep="\t", quote=FALSE)

order <- input[,c(4,8:ncol(input))]
names(order)[1] <- "id"
order <- filter(data = order,grouping = grouping,top_taxa = top_taxa)
write.table(order, "Order_taxo_heatmap.csv", sep="\t", quote=FALSE)

class <- input[,c(3,8:ncol(input))]
names(class)[1] <- "id"
class <- filter(data = class,grouping = grouping, top_taxa = top_taxa)
write.table(class, "Class_taxo_heatmap.csv", sep="\t", quote=FALSE)

phylum <- input[,c(2,8:ncol(input))]
names(phylum)[1] <- "id"
phylum <- filter(data = phylum,grouping = grouping, top_taxa = top_taxa)
write.table(phylum, "Phylum_taxo_heatmap.csv", sep="\t", quote=FALSE)

kingdom <- input[,c(1,8:ncol(input))]
names(kingdom)[1] <- "id"
kingdom <- aggregate(.~id,data=kingdom,FUN=sum)
b <- colSums(!is.na(subset(kingdom,select =c(1))))
if (b < 2) {
  rownames(kingdom) <- kingdom[,1]
  kingdom <- subset(kingdom, select = -c(id))
  kingdom <- round(kingdom, digits = 3)
  # kingdom <- (kingdom-rowMeans(kingdom))/(rowSds(as.matrix(kingdom)))[row(kingdom)]
  # kingdom <- kingdom[rowSums(is.na(kingdom)) == 0,]
  write.table(kingdom, "Kingdom_taxo_heatmap.csv", sep="\t", quote=FALSE)
} else {
  kingdom <- filter(data = kingdom,grouping = grouping, top_taxa = top_taxa)
  write.table(kingdom, "Kingdom_taxo_heatmap.csv", sep="\t", quote=FALSE)
}
