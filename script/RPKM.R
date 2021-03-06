argv <- commandArgs(T)
bamqc <- argv[1]

dfm <- read.table(bamqc, header = T, sep = '\t', row.names = 1)
samples <- rownames(dfm)
mapped <- as.numeric(gsub(',', '', sub(' .+', '', dfm$Mapped.reads))) / 1000000

RPKM <- NULL
RPM <- NULL

for (i in 1:length(samples)) {
  cnt <- read.table(paste0('count/', samples[i], '.cnt'))
  rpkm <- cnt$V3 / mapped[i] / (cnt$V2 / 1000)
  names(rpkm) <- cnt$V1
  RPKM <- cbind(RPKM, rpkm)
  
  rpm <- cnt$V3 / mapped[i]
  names(rpm) <- cnt$V1
  RPM <- cbind(RPM, rpm)
}

RPKM <- round(RPKM, 4)
colnames(RPKM) <- samples
#write.table(RPKM, 'table/virus_expression_RPKM.tsv', col.names = NA, sep = '\t', quote = F)

RPM <- round(RPM, 4)
colnames(RPM) <- samples
write.table(RPM, 'table/virus_expression_RPM.tsv', col.names = NA, sep = '\t', quote = F)
