#!/usr/bin/env nextflow

include { DADA2_DADA                } from '../../modules/dada2/dada'
include { DADA2_FILTERANDTRIM       } from '../../modules/dada2/filterAndTrim'
include { DADA2_LEARNERRORS         } from '../../modules/dada2/learnErrors'
include { DADA2_MAKESEQUENCETABLE   } from '../../modules/dada2/makeSequenceTable'
include { DADA2_MERGEPAIRS          } from '../../modules/dada2/mergePairs'
include { DADA2_REMOVEBIMERADENOVO  } from '../../modules/dada2/removeBimeraDenovo'
include { FASTQC as FASTQC_FILTERED } from '../../modules/fastqc'


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

    ch_filtered_for_fastqc = ch_filterAndTrim_out.flatMap { tuple ->
        def meta = tuple[0]
        def dir  = tuple[1]

        // Gather the files from the directory
        def f_reads = files("${dir}/*_F_filt.fastq.gz").sort()
        def r_reads = files("${dir}/*_R_filt.fastq.gz").sort()
        
        // Transpose them into clean pairs: [ [F1, R1], [F2, R2], ... ]
        def paired = [f_reads, r_reads].transpose()
        
        // Flatten out into independent elements for the FastQC process
        return paired.collectMany { f, r ->
            // Dynamically grab the sample name from the file (e.g., "LMT10_2_1_F_filt.fastq.gz" -> "LMT10_2_1")
            // This splits on the first underscore following the unique sample ID prefix
            def sample_name = f.name.take(f.name.indexOf('_F_filt'))

            // Clone the run-level meta map so each sample gets its own separate object
            def f_meta = meta.clone()
            def r_meta = meta.clone()

            f_meta.sample_name = sample_name
            r_meta.sample_name = sample_name

            return [
                [ f_meta, f, 'R1' ],
                [ r_meta, r, 'R2' ]
            ]
        }
    }

    ch_fastqc_filtered = FASTQC_FILTERED(ch_filtered_for_fastqc, "filtered")

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

    emit:
    ch_fastqc_filterandtrim = ch_fastqc_filtered.zips
    ch_seqtab_nochim = ch_removeBimeraDenovo_out

}
