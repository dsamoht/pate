process SEQTK_RC {
  
    if (workflow.containerEngine == 'singularity') {
        container = params.seqtk_singularity
    } else {
        container = params.seqtk_docker
    }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path(reads), path('fwd_primer_rc'), path('rev_primer_rc')

    script:
    def forward_primer = meta.forward_primer
    def reverse_primer = meta.reverse_primer
    """
    echo ">PRIMER\n${forward_primer}" > fwd_primer.fna
    echo ">PRIMER\n${reverse_primer}" > rev_primer.fna
    seqtk seq -r fwd_primer.fna | grep -v '>' > fwd_primer_rc
    seqtk seq -r rev_primer.fna | grep -v '>' > rev_primer_rc
    """
}
