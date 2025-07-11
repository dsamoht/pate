process KRAKENTOOLS {

    container workflow.containerEngine == 'singularity' ?
        params.krakentools_singularity : params.krakentools_docker

    publishDir "${params.output}/kraken", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    tuple val(meta), path(kraken_stdout)
    tuple val(meta), path(kraken_report)

    output:
    path('*euk_L001_R1_001.fastq.gz'), emit: euk_R1_fastq
    path('*euk_L001_R2_001.fastq.gz'), emit: euk_R2_fastq

    script:
    def sample_name = meta.sample_name
    """
    extract_kraken_reads.py \
    --include-children \
    --include-parent \
    --fastq-output \
    -k ${kraken_stdout} \
    -s1 ${reads[0]} \
    -s2 ${reads[1]} \
    -o trimmed_${sample_name}_euk_L001_R1_001.fastq \
    -o2 trimmed_${sample_name}_euk_L001_R2_001.fastq \
    -t 2759 \
    -r ${kraken_report}

    gzip trimmed_${sample_name}_euk_L001_R1_001.fastq
    gzip trimmed_${sample_name}_euk_L001_R2_001.fastq
    """
}
