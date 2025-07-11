process DADA2_MAKESEQUENCETABLE {
  
    if (workflow.containerEngine == 'singularity') {
        container = params.dada2_singularity
    } else {
        container = params.dada2_docker
    }

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(mergers)

    output:
    tuple val(meta), path("*_seqtab.rds"), emit: seqtab

    script:
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_makeSequenceTable.R ${mergers}
    mv seqtab.rds ${dada2_run_id}_seqtab.rds
    """
}
