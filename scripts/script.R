##install
library(BiocManager)
BiocManager::install(
	c(
		"ATACseqQC",
		"ChIPpeakAnno",
		"MotifDb",
		"GenomicAlignments",
		"BSgenome.Scerevisiae.UCSC.sacCer3",
		"TxDb.Scerevisiae.UCSC.sacCer3.sgdGene"
	),
	force = TRUE
)

## prepare transcript db
require(GenomicFeatures)


meta <- data.frame(c("Genome"), c("R64-1-1"))
colnames(meta) <- c("name", "value")
scer.tx <-
	makeTxDbFromGFF(
		file = "scer-updated.gtf",
		format = "gtf",
		dataSource = "Ensembl - modified",
		organism = "Saccharomyces cerevisiae",
		circ_seqs = "Mito",
		metadata = meta
	)
scer.tx
saveDb(scer.tx, file = "scer-updated.sqlite")

## read bam file
require(ATACseqQC)
require(Rsamtools)
seqinformation <- seqinfo(scer.tx)
txs <- transcripts(scer.tx)
bamfiles <- Sys.glob("~/ATACseqQC/*regions.bam")
for (bamfile in bamfiles) {
bamfile.labels <- gsub(".bam", "", basename(bamfile))

pdf(paste(bamfile.labels, "-complexity.pdf", sep =""), width = 6, height = 4)
par(mar = c(5, 5, 5, 5))
estimateLibComplexity(readsDupFreq(bamfile))
dev.off()
 
pdf(paste(bamfile.labels, "-fragment-size.pdf", sep =""), width = 6, height = 6)
par(mar = c(5, 5, 5, 5))
fragSize <- fragSizeDist(bamfile, bamfile.labels)
dev.off()

tags <- list(c("integer1"="AS","integer2"="NM", "character1"= "MD", "character2"="PG", "character3" ="RG"))
align <- readBamFile(bamfile, tag=tags, asMates=TRUE, bigFile=TRUE)
shifted_align <- shiftGAlignmentsList(align, outbam=paste(bamfile.labels, "-shifted.bam", sep =""))


tsse <- TSSEscore(shifted_align, txs)
tsse$TSSEscore
pdf(paste(bamfile.labels, "-tsse-score.pdf", sep =""), width = 6, height = 4)
par(mar = c(5, 5, 5, 5))
plot(100*(-9:10-.5), tsse$values, type="b", 
		 xlab="distance to TSS",
		 ylab="aggregate TSS score")
dev.off()
}