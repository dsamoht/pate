#!/usr/bin/env Rscript
library(dada2)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  cat("Usage: Rscript dada2_removeBimeraDenovo.R <seqtab_file>\n")
  cat("  seqtab_file: Path to seqtab (output of makeSequenceTable) (.rds)\n")
  stop("Incorrect number of arguments", call. = FALSE)
}

seqtab_file <- args[1]
seqtab <- readRDS(seqtab_file)
seqtab_nochim = removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

saveRDS(seqtab_nochim, "seqtab_nochim.rds")
