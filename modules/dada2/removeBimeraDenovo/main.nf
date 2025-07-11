process DADA2_REMOVEBIMERADENOVO {
  
    if (workflow.containerEngine == 'singularity') {
        container = params.dada2_singularity
    } else {
        container = params.dada2_docker
    }

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
