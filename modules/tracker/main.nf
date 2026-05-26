process READ_TRACKER {

    tag meta.dada2_run_id

    container params.dada2_container

    publishDir "${params.output}/tracker", mode: 'copy'

    input:
    tuple val(meta),
          path(cutadapt_logs),
          path(ft_track),
          path(dadaFs),
          path(dadaRs),
          path(mergers),
          path(seqtab_nochim)

    output:
    tuple val(meta), path("*_read_tracker.csv"), emit: read_tracker

    script:
    def dada2_run_id = meta.dada2_run_id
    def logs_string  = cutadapt_logs.join(" ")
    """
    reads_tracker.R \\
        --run_id "${dada2_run_id}" \\
        --cutadapt_logs "${logs_string}" \\
        --ft_track "${ft_track}" \\
        --dada_fs "${dadaFs}" \\
        --dada_rs "${dadaRs}" \\
        --mergers "${mergers}" \\
        --seqtab_nochim "${seqtab_nochim}"
    """
}
