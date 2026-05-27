# __pate__  
## Pipeline for Amplicon data Treatment in microbial Ecology
> [!NOTE]
__pate__ is made for short reads metabarcoding. It runs [DADA2](https://github.com/benjjneb/dada2) as the core denoising algorithm. For reproducibility and efficiency purposes, filtering parameters are chosen automatically with [FIGARO](https://github.com/Zymo-Research/figaro).

## TL;DR
```
nextflow pull dsamoth/pate  
nextflow run dsamoth/pate -profile docker --input samplesheet.csv --output pate_out
```

## Usage
### Dependencies
  - [Nextflow](https://www.nextflow.io/)  
  - [Docker](https://www.docker.com/) or [Apptainer/Singularity](https://apptainer.org/)  
