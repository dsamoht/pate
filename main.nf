#!/usr/bin/env nextflow

include { CUTADAPT                 } from './modules/cutadapt'
include { DADA2                    } from './modules/dada2'
include { DADA2_FILTERANDTRIM      } from './modules/dada2/filterAndTrim'
include { DISPATCH                 } from './workflows/dispatch'
include { FASTQC                   } from './modules/fastqc'
include { FIGARO                   } from './modules/figaro'
include { FILTER_MAGICBLAST_OUTPUT } from './modules/magicblast/filter_magicblast_output'
include { KRAKEN                   } from './modules/kraken'
include { KRAKENTOOLS              } from './modules/krakentools'
include { MAGICBLAST               } from './modules/magicblast/magicblast'
include { MAKEBLASTDB              } from './modules/magicblast/makedb'
include { SEQTK_RC                 } from './modules/seqtk/rc'
include { WF_16S                   } from './workflows/wf_16S'


workflow METABARCODING_WF {

    if (params.input == ""){
        exit 1, "Enter a valid sample sheet (--input /path/to/sample_sheet.tsv)."
    }
    if (params.output == ""){
        exit 1, "Enter a valid output directory (--output /path/to/output)."
    }

    ch_input = DISPATCH()

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
            return [ meta, [r1_trimmed, r2_trimmed] ]
        }

    // - Regroup the reads according to their run id
    // - In Figaro, use the longest amplicon length if multiple amplicons were targeted in the same run
    ch_figaro_in = ch_cutadapt_out
        .map { meta, reads ->
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
        .map { meta, fastqs -> 
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
    
    
    WF_16S(ch_by_amplicon.amplicon_16S.ifEmpty([]))
    //18S_WF(ch_cutadapt_figaro_out.amplicon_18S.ifEmpty([]))
    //16S18S_WF(ch_cutadapt_figaro_out.amplicon_16S18S.ifEmpty([]))
    //ITS_WF(ch_cutadapt_figaro_out.amplicon_ITS.ifEmpty([]))
    //COI_WF(ch_cutadapt_figaro_out.amplicon_ITS.ifEmpty([]))
    
    // - Magicblast is needed for 16S+18S "universal" primers
    // - TODO: it exectutes only if the items in the sample sheet contain `16S18S_V4V5` primers
    
    // ch_blastdb_out = MAKEBLASTDB(params.pr2_18s_db)
    // ch_magicblast_out = MAGICBLAST(ch_cutadapt_out, ch_blastdb_out)
    // ch_magicblast_filtered_out = FILTER_MAGICBLAST_OUTPUT(ch_cutadapt_out, ch_magicblast_out)
 
    //ch_filterandtrim_out = DADA2_FILTERANDTRIM(ch_dada2_in)
    //ch_kraken_out = KRAKEN(ch_cutadapt_out, params.kraken2_db)
    //ch_krakentools_out = KRAKENTOOLS(ch_cutadapt_out, ch_kraken_out.kraken_stdout, ch_kraken_out.kraken_report)

}

workflow {

    METABARCODING_WF()

}
