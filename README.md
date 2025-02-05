# NAC nextflow RNA-seq pipeline


## Introduction
This repository contains a nextflow RNA-Seq analysis pipeline, which uses Docker software container. It is designed to process raw RNA-Seq data starting from fastq and produce quantified gene expression profiles.



## Get started

### Requirements

* `Docker` and `nextflow` are required to run the RNAseq_NAC pipeline. Additional software used in the pipeline is packaged in Docker container and will be automatically downloaded during the first execution of the pipeline.
* The pipeline is compatible with all computational infrastructures. Executing the pipeline on cloud or HPC systems may require to adapt the [`nextflow.config`](https://www.nextflow.io/docs/latest/basic.html).

### Clone this repository
You can obtain the pipeline directly from GitHub:
```bash
git clone https://github.com/uschwartz/RNAseq_NAC.git
```

### Get help
```bash
nextflow run path2RNAseq/RNAseq_NAC --help
```


## Contact

Uwe Schwartz: uwe.schwartz@ur.de

## Cite

Wernig-Zorc et al., 2023, nucMACC: An optimized MNase-seq pipeline measures genome-wide nucleosome accessibility and stability. bioRxiv (https://doi.org/10.1101/2022.12.29.521985)
