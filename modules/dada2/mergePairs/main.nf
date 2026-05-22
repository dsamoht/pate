process DADA2_MERGEPAIRS {

    tag meta.dada2_run_id
  
    container params.dada2_container

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(reads), path(dadaFs), path(dadaRs)

    output:
    tuple val(meta), path("*_mergers.rds"), emit: mergers

    script:
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_mergePairs.R ${dadaFs} ${dadaRs}
    mv mergers.rds ${dada2_run_id}_mergers.rds
    """
}
