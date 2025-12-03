# __pâté__ : Pipeline for Amplicon data Treatment in microbial Ecology
> [!NOTE]
Each amplicon type has its own considerations. Their treatment must follow similar but different strategies. __Pâté__ now supports the following amplicons:  
:white_check_mark: __16S__  
:white_check_mark: __16S18S__ (universal primers)  
:white_check_mark: __18S__    
:white_check_mark: __ITS__  

## TL;DR
```
nextflow pull dsamoth/pate  
nextflow run dsamoth/pate -profile docker --input samplesheet.csv --output pate_out
```

## Usage
### Dependencies
  - [Nextflow](https://www.nextflow.io/)  
  - [Docker](https://www.docker.com/) or [Apptainer/Singularity](https://apptainer.org/)  
