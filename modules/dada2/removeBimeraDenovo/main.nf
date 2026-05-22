process DADA2_REMOVEBIMERADENOVO {

    tag meta.dada2_run_id

    container params.dada2_container

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(seqtab)

    output:
    tuple val(meta), path("*_seqtab_nochim.rds"), emit: seqtab_nochim

    script:
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_removeBimeraDenovo.R ${seqtab}
    mv seqtab_nochim.rds ${dada2_run_id}_seqtab_nochim.rds
    """
}
