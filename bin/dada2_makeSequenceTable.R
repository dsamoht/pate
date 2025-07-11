#!/usr/bin/env Rscript
library(dada2)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  cat("Usage: Rscript dada2_makeSequenceTable.R <mergers_file>\n")
  cat("  mergers_file: Path to output file of mergePairs (.rds)\n")
  stop("Incorrect number of arguments", call. = FALSE)
}

mergers_file <- args[1]

if (!file.exists(mergers_file)) {
  stop(paste("Error: mergers_file does not exist:", mergers_file), call. = FALSE)
}

cat("mergePairs output file:", mergers_file, "\n")
cat("Loading mergePairs output file...\n")
mergers <- readRDS(mergers_file)
seqtab = makeSequenceTable(mergers)
saveRDS(seqtab, "seqtab.rds")
