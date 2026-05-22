process FASTQC {

    tag "${meta.sample_name ?: meta.run_id} | ${stage} | ${orientation}"
    
    container params.fastqc_container
    
    publishDir "${params.output}/fastqc/", mode: 'copy'

    input:
    tuple val(meta), path(read), val(orientation)
    val stage // 'raw', 'trimmed', 'filtered'

    output:
    tuple val(meta), path("*_fastqc.zip"), emit: zips
    tuple val(meta), path("*_fastqc.html"), emit: htmls

    script:
    def prefix = "${meta.sample_name ?: meta.run_id}_${stage}_${orientation}"
    """
    ln -s ${read} ${prefix}.fastq.gz
    fastqc --threads ${task.cpus} --memory 6000 ${prefix}.fastq.gz
    """
}
