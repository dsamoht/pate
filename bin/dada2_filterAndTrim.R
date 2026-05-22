#!/usr/bin/env Rscript
library(dada2)

args <- commandArgs(trailingOnly = TRUE)
figaro_out <- readLines(args[1])
parameters <- c("truncLen_fwd", "truncLen_rev", "ee_fwd", "ee_rev")
for (i in seq_along(figaro_out)) {
    assign(parameters[i], as.integer(figaro_out[i]))
}

fnFs <- sort(list.files("cutadapted", pattern="_S1_L001_R1_001.fastq", full.names = TRUE))
fnRs <- sort(list.files("cutadapted", pattern="_S1_L001_R2_001.fastq", full.names = TRUE))

sample_names <- sapply(strsplit(sub("^trimmed_", "", basename(fnFs)), "_S1_L001_"), `[`, 1)

filtFs <- file.path(".", "filtered_and_trimmed", paste0(sample_names, "_F_filt.fastq.gz"))
filtRs <- file.path(".", "filtered_and_trimmed", paste0(sample_names, "_R_filt.fastq.gz"))

names(filtFs) <- sample_names
names(filtRs) <- sample_names

filterAndTrim(fnFs, filtFs, fnRs, filtRs,
            truncLen=c(truncLen_fwd, truncLen_rev),
            maxN=0,
            maxEE=c(ee_fwd, ee_rev),
            truncQ=2,
            rm.phix=TRUE,
            compress=TRUE,
            multithread=TRUE)
