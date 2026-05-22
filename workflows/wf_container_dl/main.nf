workflow WF_CONTAINER_DL {

    process BLAST {
        container params.blast_container
        script:
        """
        exit 0
        """
    }
    process CUTADAPT {
        container params.cutadapt_container
        script:
        """
        exit 0
        """
    }
    process DADA2 {
        container params.dada2_container
        script:
        """
        exit 0
        """
    }
    process FASTQC {
        container params.fastqc_container
        script:
        """
        exit 0
        """
    }
    process FIGARO {
        container params.figaro_container
        script:
        """
        exit 0
        """
    }
    process KRAKEN {
        container params.kraken_container
        script:
        """
        exit 0
        """
    }
    process KRAKENTOOLS {
        container params.krakentools_container
        script:
        """
        exit 0
        """
    }
    process MAGICBLAST {
        container params.magicblast_container
        script:
        """
        exit 0
        """
    }
    process MULTIQC {
        container params.multiqc_container
        script:
        """
        exit 0
        """
    }
    process SEQTK {
        container params.seqtk_container
        script:
        """
        exit 0
        """
    }

    BLAST()
    CUTADAPT()
    DADA2()
    FASTQC()
    FIGARO()
    KRAKEN()
    KRAKENTOOLS()
    MAGICBLAST()
    MULTIQC()
    SEQTK()

}
