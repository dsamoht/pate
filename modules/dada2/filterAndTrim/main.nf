process DADA2_FILTERANDTRIM {

    tag meta.dada2_run_id
  
    container params.dada2_container
 
    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(reads, stageAs: "cutadapted/*")

    output:
    tuple val(meta), path("*_filtered_and_trimmed", type: 'dir'), emit: res_dir
    tuple val(meta), path("*_filterAndTrim_log.rds"), emit: ft_log

    script:
    def filterAndTrimParameters = meta.figaro_params
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_filterAndTrim.R ${filterAndTrimParameters}
    mv filtered_and_trimmed ${dada2_run_id}_filtered_and_trimmed
    mv filterAndTrim_log.rds ${dada2_run_id}_filterAndTrim_log.rds
    """
}
