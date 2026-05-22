process CUTADAPT {
    
    tag meta.sample_name

    container params.cutadapt_container

    publishDir "${params.output}/cutadapt", mode: 'copy', pattern: "*_cutadapt.log"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('trimmed_*_R1_*.fastq.gz'), path('trimmed_*_R2_*.fastq.gz'), path('*_cutadapt.log')

    script:
    def forward_primer = meta.forward_primer
    def reverse_primer = meta.reverse_primer
    def forward_primer_rc = meta.forward_primer_rc
    def reverse_primer_rc = meta.reverse_primer_rc
    def sample_name = meta.sample_name
    def longest_primer = [ forward_primer.length().toInteger(), reverse_primer.length().toInteger() ].max()
    def min_length = (meta.reads_length.toInteger() - longest_primer - 5 )

    """
    cutadapt \
    --cores ${task.cpus} \
    -g ${forward_primer} \
    -a ${reverse_primer_rc} \
    -G ${reverse_primer} \
    -A ${forward_primer_rc} \
    --revcomp \
    -o trimmed_${sample_name}_S1_L001_R1_001.fastq.gz \
    -p trimmed_${sample_name}_S1_L001_R2_001.fastq.gz \
    --discard-untrimmed \
    -m ${min_length} \
    -l ${min_length} \
    -L ${min_length} \
    ${reads[0]} \
    ${reads[1]} > ${sample_name}_cutadapt.log
    """
}
