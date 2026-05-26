#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(dada2))

# ── 1. Parse Named Arguments Using Base R ────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
opt  <- list()

i <- 1
while (i <= length(args)) {
    if (startsWith(args[i], "--")) {
        key <- sub("^--", "", args[i])
        opt[[key]] <- args[i + 1]
        i <- i + 2
    } else {
        i <- i + 1
    }
}

# Split the space-separated log string into a vector of filenames
cutadapt_log_files <- strsplit(opt$cutadapt_logs, " ")[[1]]


# ── 2. Parse All Cutadapt Logs Dynamically ────────────────────────────────────
raw_counts      <- c()
cutadapt_counts <- c()

for (logfile in cutadapt_log_files) {
    if (!file.exists(logfile)) next
    log_lines <- readLines(logfile)
    
    s_name <- sub("_cutadapt\\.log$", "", basename(logfile))
    
    # Target the lines we want
    raw_line <- grep("Total read pairs processed:", log_lines, value = TRUE)
    cut_line <- grep("Pairs written \\(passing filters\\):", log_lines, value = TRUE)
    
    raw_cnt <- 0
    if (length(raw_line) > 0) {
        match <- regmatches(raw_line, regexec(":\\s*([0-9,]+)", raw_line))[[1]]
        if (length(match) >= 2) raw_cnt <- as.integer(gsub(",", "", match[2]))
    }
    
    cut_cnt <- 0
    if (length(cut_line) > 0) {
        match <- regmatches(cut_line, regexec(":\\s*([0-9,]+)", cut_line))[[1]]
        if (length(match) >= 2) cut_cnt <- as.integer(gsub(",", "", match[2]))
    }

    raw_counts[s_name]      <- raw_cnt
    cutadapt_counts[s_name] <- cut_cnt
}

# ── 3. Load and Normalize filterAndTrim Tracking Matrix ───────────────────────
ft_track <- readRDS(opt$ft_track)


# Clean DADA2 matrix row names (e.g., "sample_m_S1_L001_F_filt.fastq.gz" -> "sample_m")
rownames(ft_track) <- sub("_S1_L001_.*$", "", basename(rownames(ft_track)))
rownames(ft_track) <- sub("trimmed_", "", basename(rownames(ft_track)))
samples <- rownames(ft_track)


# ── 4. Load and Normalize Denoised Vector Lists (dadaFs / dadaRs) ─────────────
dadaFs <- readRDS(opt$dada_fs)
dadaRs <- readRDS(opt$dada_rs)

denoised_F <- sapply(dadaFs, function(x) sum(getUniques(x)))
denoised_R <- sapply(dadaRs, function(x) sum(getUniques(x)))

names(denoised_F) <- sub("_F_filt.*$", "", basename(names(denoised_F)))
names(denoised_R) <- sub("_R_filt.*$", "", basename(names(denoised_R)))


# ── 5. Load and Normalize Merged Counts ───────────────────────────────────────
mergers <- readRDS(opt$mergers)
merged  <- sapply(mergers, function(x) sum(getUniques(x)))
names(merged) <- sub("_F_filt.*$", "", basename(names(merged)))


# ── 6. Load and Normalize Non-Chimeric Track Counts ───────────────────────────
seqtab_nochim  <- readRDS(opt$seqtab_nochim)
nonchim        <- rowSums(seqtab_nochim)
names(nonchim) <- sub("_F_filt.*$", "", basename(names(nonchim)))

# ── 7. Assemble Tracker DataFrame Safely ──────────────────────────────────────
# Using as.vector() ensures that any unmatched sample returns NA instead of breaking lengths
tracker <- data.frame(
  sample        = samples,
  raw           = as.vector(raw_counts[samples]),
  cutadapt      = as.vector(cutadapt_counts[samples]),
  filterAndTrim = as.vector(ft_track[samples, "reads.out"]),
  denoisedF     = as.vector(denoised_F[samples]),
  denoisedR     = as.vector(denoised_R[samples]),
  merged        = as.vector(merged[samples]),
  nonchim       = as.vector(nonchim[samples]),
  stringsAsFactors = FALSE
)


# ── 8. Write Output File ──────────────────────────────────────────────────────
out_file <- paste0(opt$run_id, "_read_tracker.csv")
write.csv(tracker, out_file, row.names = FALSE)
cat("Successfully generated tracking table: ", out_file, "\n")