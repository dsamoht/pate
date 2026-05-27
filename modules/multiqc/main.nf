process MULTIQC {

    tag "${meta}"
    
    container params.multiqc_container

    publishDir "${params.output}/multiqc", mode: 'copy'

    input:
    tuple val(meta), path(multiqc_files, stageAs: "?/*")
    path(config)

    output:
    tuple val(meta), path("*.html"), emit: report
    tuple val(meta), path("*_data"), emit: data

    script:
    """
    multiqc -c ${config} .
    mv *.html multiqc_${meta}.html
    mv *_data multiqc_${meta}_data
    """
}
