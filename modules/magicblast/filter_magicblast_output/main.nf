process FILTER_MAGICBLAST_OUTPUT {
    if (workflow.containerEngine == 'singularity') {
        container = params.magicblast_singularity
    } else {
        container = params.magicblast_docker
    }

    publishDir "${params.output}/magicblast", mode: 'copy'

    input:
    tuple val(meta), path(magicblast_out)

    output:
    path '*_18S_headers.txt', emit: magicblast_filtered_out

    script:
    def sample_name = meta.sample_name
    """
    cut -f 1,2,3,7,8,16 ${magicblast_out} | sed '1d' | sed '1d' | \
      sed 's/# Fields: //' | tr " " "_" | \
      awk -F \$'\t' ' BEGIN { OFS=FS } NR==1 { \$7="%_query_aln"; print \$0 } NR>1 { print \$0, (\$5-\$4)/\$6*100 } ' \
      > "${sample_name}"_mblast_out_mod.txt
    
    awk ' \$3 > 90 && \$7 > 35 ' "${sample_name}"_mblast_out_mod.txt | \
        cut -f 1 | uniq -d > "${sample_name}"_18S_headers.txt
    """
}
