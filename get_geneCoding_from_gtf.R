# set path to dir with complete GTF file
setwd("/Users/admin/Annotation/genome/")

#load complete GTF file containing all biotypes
gtf.name<-list.files()[grep(".gtf",list.files())]
#first lines are here header
gtf<-read.delim(gtf.name,header=F, skip = 5)

#get biotype (tested with GTFs obtained from ENCODE)
biotype.raw<-sapply(strsplit(as.character(gtf$V9), split = ";", fixed=T), function(x) x[grep("gene_biotype",x)])
biotype<-sapply(strsplit(biotype.raw, split = " "),function(x) x[3])

#get only protein coding
gtf.sub<-gtf[(which(biotype %in% c("protein_coding"))),]

write.table(gtf.sub,file="protein_coding.gtf", quote=F,
            sep="\t", row.names = F, col.names = F)
