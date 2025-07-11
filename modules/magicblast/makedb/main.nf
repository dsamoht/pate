process MAKEBLASTDB {

    if (workflow.containerEngine == 'singularity') {
        container = params.blast_singularity
    } else {
        container = params.blast_docker
    }

    input:
    path(pr2_fasta)

    output:
    path('pr2-magicblast-db')
    
    script:
    """
    makeblastdb \
        -in ${pr2_fasta} \
        -dbtype nucl \
        -parse_seqids \
        -out pr2-blastdb

    mkdir pr2-magicblast-db
    mv pr2-blastdb.* ./pr2-magicblast-db
    """
}
