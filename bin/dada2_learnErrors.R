#!/usr/bin/env Rscript
library(dada2)

filtFs <- sort(list.files(".", pattern = "_F_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))
filtRs <- sort(list.files(".", pattern = "_R_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))

errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)

saveRDS(errF, file = "errF.rds")
saveRDS(errR, file = "errR.rds")
