process DADA2_LEARNERRORS {
  
    if (workflow.containerEngine == 'singularity') {
        container = params.dada2_singularity
    } else {
        container = params.dada2_docker
    }

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_errF.rds"), emit: errF
    tuple val(meta), path("*_errR.rds"), emit: errR

    script:
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_learnErrors.R
    mv errF.rds ${dada2_run_id}_errF.rds
    mv errR.rds ${dada2_run_id}_errR.rds
    """
}
