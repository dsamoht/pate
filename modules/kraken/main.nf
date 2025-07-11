process KRAKEN {

    container workflow.containerEngine == 'singularity' ?
            params.kraken_singularity : params.kraken_docker

    publishDir "${params.output}/kraken", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path kraken_db

    output:
    tuple val(meta), path('*.kraken'), emit: kraken_report
    tuple val(meta), path('*.kraken.out'), emit: kraken_stdout

    script:
    def sample = meta.sample_name

    """
    kraken2 --db ${kraken_db} --report ${sample}.kraken --threads ${task.cpus} --paired ${reads[0]} ${reads[1]} > ${sample}.kraken.out
    """
}
