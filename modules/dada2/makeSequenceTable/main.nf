process DADA2_MAKESEQUENCETABLE {

    tag meta.dada2_run_id

    container params.dada2_container

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
