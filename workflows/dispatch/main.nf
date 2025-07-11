#!/usr/bin/env nextflow

workflow DISPATCH {

    ch_input = Channel
        .from(file(params.input))
        .splitCsv(header: true)
        .map { row ->
                if (row.size() == 9) {
                    def meta = [:]
                    meta.sample_name = row.sample_name
                    meta.amplicon = row.amplicon
                    meta.amplicon_length = row.amplicon_length
                    meta.run_id = row.run_id
                    meta.dada2_run_id = "${row.run_id}_${row.amplicon}"
                    meta.reads_length = row.reads_length
                    meta.forward_primer = row.forward_primer
                    meta.reverse_primer = row.reverse_primer
                    def forward_reads = file(row.forward_reads, checkIfExists: true)
                    def reverse_reads = file(row.reverse_reads, checkIfExists: true)

                    return [ meta, [ forward_reads, reverse_reads ] ]
     
                } else {
                    exit 1, "Error in ${params.input}. Each row must contain 9 columns."
                }
        }

    emit:
    ch_input
}
