#!/usr/bin/env nextflow

include { CUTADAPT                 } from './modules/cutadapt'
include { DISPATCH                 } from './workflows/dispatch'
include { FASTQC as FASTQC_RAW     } from './modules/fastqc'
include { FASTQC as FASTQC_TRIMMED } from './modules/fastqc'
include { FIGARO                   } from './modules/figaro'
include { MULTIQC                  } from './modules/multiqc'
include { READ_TRACKER             } from './modules/tracker'
include { SEQTK_RC                 } from './modules/seqtk/rc'
include { WF_16S                   } from './workflows/wf_16s'


workflow PATE {

    if (params.input == ""){
        exit 1, "Enter a valid sample sheet (--input /path/to/samplesheet.csv)."
    }
    if (params.output == ""){
        exit 1, "Enter a valid output directory (--output /path/to/output)."
    }

    ch_input = DISPATCH()

    ch_raw_for_fastqc = ch_input.flatMap { meta, reads ->
        [
            [ meta, reads[0], 'raw', 'R1' ],
            [ meta, reads[1], 'raw', 'R2' ]
        ]
    }
    ch_fastqc_raw = FASTQC_RAW(ch_raw_for_fastqc)
    
    // - Gather FastQC zips for multiqc reporting
    ch_fastqc_raw_zips = ch_fastqc_raw.zips.map { meta, zip -> 
        return [ meta.dada2_run_id, zip ]
    }

    // - Get the reverse-complement of the forward and reverse primers
    ch_seqtk_rc_out = SEQTK_RC(ch_input)
        .map { meta, reads, fwd_primer_rc, rev_primer_rc ->
            meta.forward_primer_rc = fwd_primer_rc.text.trim()
            meta.reverse_primer_rc = rev_primer_rc.text.trim()
            return [ meta, reads ]
    }

    // - Remove the primers from the reads in all their possible orientations
    // - Trim the reads to the same length -> [reads length] minus [longest_primer] minus 5
    ch_cutadapt_out = CUTADAPT(ch_seqtk_rc_out)
        .map { meta, r1_trimmed, r2_trimmed, log ->
            return [ meta, [r1_trimmed, r2_trimmed], log ]
        }
    // - Gather cutadapt logs for multiQC reporting
    ch_cutadapt_logs  = ch_cutadapt_out.map { meta, reads, log -> [ meta.dada2_run_id, log ] }
    
    ch_fastqc_trimmed = FASTQC_TRIMMED(
        ch_cutadapt_out.flatMap { meta, reads, log ->
        [
            [ meta, reads[0], 'trimmed', 'R1' ],
            [ meta, reads[1], 'trimmed', 'R2' ]
        ]
    })
    // - Gather FastQC zips for multiQC reporting
    ch_fastqc_trimmed_zips = ch_fastqc_trimmed.zips.map { meta, zip -> 
        return [ meta.dada2_run_id, zip ]
    }

    // - Regroup the reads according to their run id
    // - In Figaro, use the longest amplicon length if multiple amplicons were targeted in the same run
    ch_figaro_in = ch_cutadapt_out
        .map { meta, reads, log ->
            return [ meta.run_id, meta, reads ]
        }
        .groupTuple(by: 0)
        .map { run_id, meta, reads ->
            def _reads = reads.flatten()
            def figaro_length = meta.collect { it ->
                it.amplicon_length
            }.max()
            meta.each { it ->
                it.figaro_length = figaro_length
            }
            return [ meta, _reads ]
        }

    // - Run Figaro
    ch_figaro_out = FIGARO(ch_figaro_in)
        .map { meta, param ->
            return [ meta[0].run_id, param ]
        }

    ch_cutadapt_out_keyed = ch_cutadapt_out
        .map { meta, fastqs, log -> 
            [ meta.run_id, [meta, fastqs] ] 
        }
    
    // - Add Figaro filtering parameters to the cutadapt output
    ch_cutadapt_figaro_out = ch_cutadapt_out_keyed
        .combine(ch_figaro_out, by: 0)
        .map { run_id, meta_and_reads, param  ->
            def meta = meta_and_reads[0]
            meta.figaro_params = param
            def reads = meta_and_reads[1]
            return [ meta, reads ] }


    // - Pipeline becomes more amplicon-specific from here on
    // - Produce a channel for each amplicon type
    ch_cutadapt_figaro_out       
        .map { it -> 
            def key = [it[0].dada2_run_id, it[0].amplicon]
            return [ key, it ]
        }
        .groupTuple()
        .branch { it ->
        amplicon_16S: it[0][1] == '16S'
            return it[1]           
        amplicon_18S: it[0][1] == '18S'
            return it[1]
        amplicon_16S18S: it[0][1] == '16S18S'
            return it[1]
        amplicon_ITS: it[0][1] == 'ITS'
            return it[1]
        amplicon_COI: it[0][1] == 'COI'
            return it[1]
        }
        .set { ch_by_amplicon }
    
    
    ch_processed_16s = WF_16S(ch_by_amplicon.amplicon_16S.ifEmpty([]))
    
    // - Gather FastQC zips for multiQC reporting
    ch_fastqc_filt_zips = ch_processed_16s.ch_fastqc_filterandtrim.map { meta, zip -> 
        return [ meta.dada2_run_id, zip ]
    }

    ch_multiqc_in = ch_fastqc_raw_zips
        .mix(ch_fastqc_trimmed_zips)
        .mix(ch_fastqc_filt_zips)
        .mix(ch_cutadapt_logs)
        .groupTuple()
        .map { dada2_run_id, files ->
            return [ dada2_run_id, files.flatten() ]
        }

    ch_multiqc_config = channel.value(file("${projectDir}/assets/multiqc_config.yml"))
    ch_multiqc_out = MULTIQC(ch_multiqc_in, ch_multiqc_config)

    // Group individual sample cutadapt logs by their dada2_run_id
    ch_cutadapt_run_logs = ch_cutadapt_logs
        .groupTuple(by: 0)

    // Clear out the complex meta maps from the WF_16S outputs, reducing them to simple [dada2_run_id, file]
    ch_ft_log_mapped     = ch_processed_16s.ch_ft_log.map     { meta, file -> [ meta.dada2_run_id, file ] }
    ch_errF_mapped       = ch_processed_16s.ch_errF.map       { meta, file -> [ meta.dada2_run_id, file ] }
    ch_errR_mapped       = ch_processed_16s.ch_errR.map       { meta, file -> [ meta.dada2_run_id, file ] }
    ch_dadaFs_mapped     = ch_processed_16s.ch_dadaFs.map     { meta, file -> [ meta.dada2_run_id, file ] }
    ch_dadaRs_mapped     = ch_processed_16s.ch_dadaRs.map     { meta, file -> [ meta.dada2_run_id, file ] }
    ch_mergers_mapped    = ch_processed_16s.ch_mergers.map    { meta, file -> [ meta.dada2_run_id, file ] }
    ch_seqtab_no_mapped  = ch_processed_16s.ch_seqtab_nochim.map { meta, file -> [ meta.dada2_run_id, file ] }

    // 3. Declaratively join everything together based strictly on matching IDs
    ch_read_tracker_in = ch_cutadapt_run_logs
        .join(ch_ft_log_mapped)
        .join(ch_errF_mapped)
        .join(ch_errR_mapped)
        .join(ch_dadaFs_mapped)
        .join(ch_dadaRs_mapped)
        .join(ch_mergers_mapped)
        .join(ch_seqtab_no_mapped)
        .map { dada2_run_id, cutadapt_logs, ft_track, errF, errR, dadaFs, dadaRs, mergers, seqtab_nochim ->
            // Reconstruct the structured return tuple cleanly
            def meta = [ dada2_run_id: dada2_run_id ]
            return [ meta, cutadapt_logs, ft_track, dadaFs, dadaRs, mergers, seqtab_nochim ]
        }
    
    ch_read_tracker_out = READ_TRACKER(ch_read_tracker_in)

}

workflow {

    PATE()

}
