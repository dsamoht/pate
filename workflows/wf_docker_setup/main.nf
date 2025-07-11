workflow WF_DOCKER_SETUP {

    process BLAST {
        container = params.blast_docker
        script:
        """
        exit 0
        """
    }
    process CUTADAPT {
        container = params.cutadapt_docker
        script:
        """
        exit 0
        """
    }
    process DADA2 {
        container = params.dada2_docker
        script:
        """
        exit 0
        """
    }
    process FASTQC {
        container = params.fastqc_docker
        script:
        """
        exit 0
        """
    }
    process FIGARO {
        container = params.figaro_docker
        script:
        """
        exit 0
        """
    }
    process KRAKEN {
        container = params.kraken_docker
        script:
        """
        exit 0
        """
    }
    process KRAKENTOOLS {
        container = params.krakentools_docker
        script:
        """
        exit 0
        """
    }
    process MAGICBLAST {
        container = params.magicblast_docker
        script:
        """
        exit 0
        """
    }
    process MULTIQC {
        container = params.multiqc_docker
        script:
        """
        exit 0
        """
    }
    process SEQTK {
        container = params.seqtk_docker
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
