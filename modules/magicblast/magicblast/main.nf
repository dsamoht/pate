process MAGICBLAST {

    if (workflow.containerEngine == 'singularity') {
        container = params.magicblast_singularity
    } else {
        container = params.magicblast_docker
    }

    publishDir "${params.output}/magicblast", mode: 'copy'
    
    input:
    tuple val(meta), path(reads)
    path(pr2_18s_blast_db) 

    output:
    tuple val(meta), path('*_mblast_out.txt'), emit: magicblast_out

    script:
    def sample_name = meta.sample_name
    """
    magicblast -db ${pr2_18s_blast_db}/pr2-blastdb -query ${reads[0]} \
                -query_mate ${reads[1]} -infmt fastq \
                -out ${sample_name}_mblast_out.txt -outfmt tabular \
                -num_threads ${task.cpus} -splice F -no_unaligned
    """
}
