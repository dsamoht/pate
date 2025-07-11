process DADA2_FILTERANDTRIM {
  
    if (workflow.containerEngine == 'singularity') {
        container = params.dada2_singularity
    } else {
        container = params.dada2_docker
    }

    publishDir "${params.output}/dada2", mode: 'copy'

    input:
    tuple val(meta), path(reads, stageAs: "cutadapted/*")

    output:
    tuple val(meta), path("*_filtered_and_trimmed", type: 'dir')

    script:
    def filterAndTrimParameters = meta.figaro_params
    def dada2_run_id = meta.dada2_run_id
    """
    dada2_filterAndTrim.R ${filterAndTrimParameters}
    mv filtered_and_trimmed ${dada2_run_id}_filtered_and_trimmed
    """
}
