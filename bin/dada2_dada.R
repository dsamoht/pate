#!/usr/bin/env Rscript
library(dada2)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  cat("Usage: Rscript dada2_dada.R <errF_file> <errR_file>\n")
  cat("  errF_file: Path to forward error model file (.rds)\n")
  cat("  errR_file: Path to reverse error model file (.rds)\n")
  stop("Incorrect number of arguments", call. = FALSE)
}

# Assign arguments to variables
errF_file <- args[1]
errR_file <- args[2]

# Check if files exist
if (!file.exists(errF_file)) {
  stop(paste("Error: errF file does not exist:", errF_file), call. = FALSE)
}

if (!file.exists(errR_file)) {
  stop(paste("Error: errR file does not exist:", errR_file), call. = FALSE)
}

# Print received arguments for verification
cat("Forward error model file:", errF_file, "\n")
cat("Reverse error model file:", errR_file, "\n")

# Load the error models
cat("Loading error models...\n")
errF <- readRDS(errF_file)
errR <- readRDS(errR_file)


filtFs <- sort(list.files(".", pattern = "_F_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))
filtRs <- sort(list.files(".", pattern = "_R_filt\\.fastq\\.gz$", full.names = TRUE, recursive = TRUE))

dadaFs <- dada(filtFs, err=errF, multithread=TRUE)
dadaRs <- dada(filtRs, err=errR, multithread=TRUE)

saveRDS(dadaFs, "dadaFs.rds")
saveRDS(dadaRs, "dadaRs.rds")
