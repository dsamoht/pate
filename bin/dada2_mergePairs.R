#!/usr/bin/env Rscript
library(dada2)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  cat("Usage: Rscript dada2_mergePairs.R <dadaFs_file> <dadaRs_file>\n")
  cat("  dadaFs_file: Path to forward denoised file (.rds)\n")
  cat("  dadaRs_file: Path to reverse denoised file (.rds)\n")
  stop("Incorrect number of arguments", call. = FALSE)
}

# Assign arguments to variables
dadaFs_file <- args[1]
dadaRs_file <- args[2]

# Check if files exist
if (!file.exists(dadaFs_file)) {
  stop(paste("Error: errF file does not exist:", dadaFs_file), call. = FALSE)
}

if (!file.exists(dadaRs_file)) {
  stop(paste("Error: errR file does not exist:", dadaRs_file), call. = FALSE)
}

# Print received arguments for verification
cat("Forward denoised file:", dadaFs_file, "\n")
cat("Reverse denoised file:", dadaRs_file, "\n")

# Load the denoised files
cat("Loading denoised files...\n")
dadaFs <- readRDS(dadaFs_file)
dadaRs <- readRDS(dadaRs_file)

filtFs <- sort(list.files(".", pattern = "_F_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))
filtRs <- sort(list.files(".", pattern = "_R_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))

mergers = mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)

saveRDS(mergers, "mergers.rds")
