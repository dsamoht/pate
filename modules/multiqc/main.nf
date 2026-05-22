process MULTIQC {

    tag "${meta}"
    
    container params.multiqc_container

    publishDir "${params.output}/multiqc", mode: 'copy'

    input:
    tuple val(meta), path(multiqc_files, stageAs: "?/*")

    output:
    tuple val(meta), path("*.html"), emit: report
    tuple val(meta), path("*_data"), emit: data

    script:
    """
    cp ${projectDir}/assets/* .
    multiqc -c ./multiqc_config.yml .
    mv *.html multiqc_${meta}.html
    mv *_data multiqc_${meta}_data
    """
}
