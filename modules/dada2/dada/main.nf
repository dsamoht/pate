process DADA2_DADA {

    tag meta.dada2_run_id
  
    container params.dada2_container

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(reads), path(errors_fwd), path(errors_rev)

    output:
    tuple val(meta), path("*_dadaFs.rds"), emit: dadaFs
    tuple val(meta), path("*_dadaRs.rds"), emit: dadaRs

    script:
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_dada.R ${errors_fwd} ${errors_rev}
    mv dadaFs.rds ${dada2_run_id}_dadaFs.rds
    mv dadaRs.rds ${dada2_run_id}_dadaRs.rds
    """
}
