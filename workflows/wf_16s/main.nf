#!/usr/bin/env nextflow

include { DADA2_DADA               } from '../../modules/dada2/dada'
include { DADA2_FILTERANDTRIM      } from '../../modules/dada2/filterAndTrim'
include { DADA2_LEARNERRORS        } from '../../modules/dada2/learnErrors'
include { DADA2_MAKESEQUENCETABLE  } from '../../modules/dada2/makeSequenceTable'
include { DADA2_MERGEPAIRS         } from '../../modules/dada2/mergePairs'
include { DADA2_REMOVEBIMERADENOVO } from '../../modules/dada2/removeBimeraDenovo'


workflow WF_16S {

    take:
    ch_dada2_run

    main:

    // - Format the channel emission to be compatible with DADA2 pipeline
    ch_dada2_in = ch_dada2_run
    .map { samples_list ->
        // Take the first sample's metadata and remove sample_name
        // All the information in the meta is expected to be the same for all samples in a run
        def first_meta = samples_list[0][0]
        def combined_meta = first_meta.findAll { key, value -> key != 'sample_name' }
        // Collect all reads from all samples in this run
        def all_reads = samples_list.collect { sample_info, reads ->
            reads
        }
        .flatten()

        return [combined_meta, all_reads]
    }

    ch_filterAndTrim_out = DADA2_FILTERANDTRIM(ch_dada2_in)
    ch_learnErrors_out = DADA2_LEARNERRORS(ch_filterAndTrim_out)
    ch_dada_in = ch_filterAndTrim_out
        .join(ch_learnErrors_out.errF)
        .join(ch_learnErrors_out.errR)
    
    ch_dada_out = DADA2_DADA(ch_dada_in)
    ch_mergePairs_in = ch_filterAndTrim_out
        .join(ch_dada_out.dadaFs)
        .join(ch_dada_out.dadaRs)
    
    ch_mergePairs_out = DADA2_MERGEPAIRS(ch_mergePairs_in)
    ch_makeSequenceTable_out = DADA2_MAKESEQUENCETABLE(ch_mergePairs_out)
    ch_removeBimeraDenovo_out = DADA2_REMOVEBIMERADENOVO(ch_makeSequenceTable_out)

    //emit:
    //ch_filterAndTrim_out

}
