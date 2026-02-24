# RNAseq_NAC - Nextflow RNA-seq Analysis Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A525.04.0-23aa62.svg)](https://www.nextflow.io/)
[![Docker](https://img.shields.io/badge/docker-enabled-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A robust and flexible Nextflow DSL2 pipeline for RNA-seq data analysis, from raw FASTQ files to quantified gene expression profiles. This pipeline uses Docker containers for reproducibility and can run on local machines, HPC clusters, or cloud infrastructure.

## Table of Contents
- [Overview](#overview)
- [Pipeline Features](#pipeline-features)
- [Pipeline Workflow](#pipeline-workflow)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Parameters](#parameters)
- [Input Data](#input-data)
- [Output](#output)
- [Test Run](#test-run)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Citation](#citation)
- [Contact](#contact)

## Overview

RNAseq_NAC is a comprehensive RNA-seq analysis pipeline built with Nextflow DSL2. It automates the entire RNA-seq workflow including:
- Quality control (FastQC, MultiQC)
- Optional adapter trimming (Trim Galore)
- Read alignment (STAR)
- BAM file processing and duplicate marking (Picard)
- Coverage visualization (BigWig generation)
- RNA-seq specific QC (Qualimap, dupRadar)
- Gene expression quantification (featureCounts)

The pipeline is designed to be flexible, supporting both single-end and paired-end sequencing data, with configurable strandedness options.

## Pipeline Features

✨ **Key Features:**
- **Nextflow DSL2**: Modern, modular pipeline structure
- **Docker Integration**: All tools packaged in containers for reproducibility
- **Flexible Configuration**: Supports both single-end and paired-end data
- **Comprehensive QC**: Multiple quality control steps with aggregated reports
- **Strand-specific**: Configurable strandedness for accurate quantification
- **Scalable**: Runs on local machines, HPC clusters, or cloud platforms
- **Test Mode**: Quick validation with subset of reads
- **Automated Reports**: Pipeline execution reports and metrics

## Pipeline Workflow

```
Raw FASTQ Files
    ↓
FastQC (Quality Control)
    ↓
MultiQC (Aggregate QC Report)
    ↓
[Optional] Trim Galore (Adapter Trimming)
    ↓
STAR (Alignment to Reference Genome)
    ↓
├─→ BigWig Generation (Coverage Tracks)
├─→ Picard MarkDuplicates (Duplicate Detection)
├─→ BAM Indexing
├─→ Qualimap (RNA-seq QC on protein-coding genes)
├─→ dupRadar (Duplication Rate Analysis on protein-coding genes)
└─→ featureCounts (Gene Expression Quantification)
    ↓
MultiQC (Final Comprehensive Report)
```

## Requirements

### Software Dependencies
- **Nextflow** ≥ 25.04.0 ([installation guide](https://www.nextflow.io/docs/latest/getstarted.html))
- **Docker** ([installation guide](https://docs.docker.com/get-docker/))
  - bioinformatics tools are packaged in Docker container

### System Requirements
- **Minimum**: 8 GB RAM, 4 CPUs
- **Recommended**: 50 GB RAM, 12 CPUs (for large genomes like human/mouse)
- **Storage**: Sufficient disk space for reference genome, index files, and output data

### Reference Data Required
- **STAR genome index**: Pre-built STAR index for your organism
- **GTF annotation file**: Gene annotation in GTF format
  - --gtfFile "GTF" | GTF file name for read counting (default `protein_coding.gtf`). Should be placed in --gtfPath
  - GTF file consisting only of protein-coding genes named `protein_coding.gtf` is required to be present in --gtfPath, as it is used for qualimap and dupRadar. See script `get_geneCoding_from_gtf.R` to generate one.

## Installation

### 1. Install Nextflow
```bash
# Install Nextflow
curl -s https://get.nextflow.io | bash
mv nextflow ~/bin/  # Or another directory in your PATH
```

### 2. Install Docker
Follow the [official Docker installation guide](https://docs.docker.com/get-docker/) for your operating system.

### 3. Clone the Pipeline
```bash
git clone https://github.com/uschwartz/RNAseq_NAC.git

```

The Docker container will be automatically downloaded on the first pipeline run.

## Quick Start

Run the pipeline with default test parameters with custom parameters:

```bash
nextflow run RNAseq_NAC \
  --fastqPath /path/to/fastq \
  --outPath /path/to/output \
  --STARidxPath /path/to/STAR/index \
  --gtfPath /path/to/gtf/files
```

## Usage

### Display Help Message
```bash
nextflow run RNAseq_NAC --help
```

### Test Run (extracting 100,000 reads from one sample)
The pipeline includes a `--testRUN` mode for quick validation of provided data.
Recommended to check strandness (see qualimap report) and adapter content (fastqc reports)
before running the pipeline on the whole data set

```bash
nextflow run RNAseq_NAC \
  --testRUN true \
  --fastqPath /data/raw_fastq \
  --outPath /results/test \
  --STARidxPath /references/mm10/STARidx \
  --gtfPath /references/mm10/annotation
```

## Parameters

### Mandatory Arguments

| Parameter | Description |
|-----------|-------------|
| `--fastqPath` | Path to directory containing FASTQ files |
| `--outPath` | Path to write output files |
| `--STARidxPath` | Path to STAR genome index directory |
| `--gtfPath` | Path to directory containing GTF annotation files |

### Optional Arguments - General

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--pairedEnd` | `false` | Specify if data is paired-end (`true`/`false`) |
| `--strandness` | `reverse` | Library strandedness (`forward`/`reverse`/`unstranded`) |
| `--testRUN` | `false` | Test run with first 100,000 reads (`true`/`false`) |
| `--gtfFile` | `protein_coding.gtf` | GTF file name for gene counting (located in `gtfPath`) |
| `--exprName` | `*.fastq.gz` | Pattern to match single-end FASTQ files |
| `--exprNamePE` | `*{1,2}.fastq.gz` | Pattern to match paired-end FASTQ files |
| `--highMemory` | `false` | Prevent memory overflow in STAR (`true`/`false`) |

### Optional Arguments - Trimming

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--trim` | `false` | Enable adapter trimming with Trim Galore (`true`/`false`) |
| `--adapters` | `trimmingAdapter/NGS_contaminants.fa` | Path to adapter sequences file (FASTA format) |

### Optional Arguments - STAR Alignment

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--zipSTAR` | `gunzip` | Decompression command used by STAR |

## Input Data

### FASTQ File Naming

**Single-End Data:**
- Files should match the pattern specified in `--exprName` (default: `*.fastq.gz`)
- Example: `sample1.fastq.gz`, `sample2.fastq.gz`

**Paired-End Data:**
- Files should match the pattern specified in `--exprNamePE` (default: `*{1,2}.fastq.gz`)
- Example: `sample1_1.fastq.gz`, `sample1_2.fastq.gz`
- Forward reads: `*_1.fastq.gz`
- Reverse reads: `*_2.fastq.gz`

### Reference Genome Files

**STAR Index:**
```
STARidxPath/
├── Genome
├── SA
├── SAindex
├── chrNameLength.txt
└── [other STAR index files]
```

**GTF Annotation:**
```
gtfPath/
├── protein_coding.gtf          # Protein-coding genes only (required)
├── all_genes.gtf               # All annotated genes (optional)
└── protein_coding_and_lincRNA.gtf  # Protein-coding + lincRNA (optional)
```

## Output

The pipeline generates the following outputs in the specified `--outPath`:

```
outPath/
├── fastqc/                    # FastQC quality reports
│   └── *.html, *.zip
├── multiqc/                   # MultiQC aggregated reports
│   ├── multiqc_raw.html       # QC of raw reads
│   └── multiqc_final.html     # Final comprehensive report
├── trimming/                  # Trim Galore outputs (if --trim true)
│   └── *_trimmed.fq.gz
├── star/                      # STAR alignment outputs
│   ├── *.bam                  # Aligned reads
│   └── *_Log.final.out        # Alignment statistics
├── bigwigs/                   # Coverage tracks
│   └── *.bw
├── markduplicates/            # Duplicate-marked BAM files
│   ├── *.bam
│   └── *.metrics.txt
├── qualimap/                  # Qualimap RNA-seq QC
│   └── */qualimapReport.html
├── dupradar/                  # dupRadar duplication analysis
│   └── *.dupradar.pdf
├── counts/                    # Gene expression counts
│   ├── counts.txt             # Raw counts matrix
│   └── counts.txt.summary     # Counting statistics
└── pipeline_info/             # Pipeline execution reports
    ├── execution_timeline.html
    ├── execution_report.html
    └── execution_trace.txt
```

### Key Output Files

- **counts.txt**: Gene expression count matrix (rows = genes, columns = samples)
- **multiqc_final.html**: Comprehensive quality control report for all samples
- **\*.bam**: Aligned and duplicate-marked BAM files for downstream analysis
- **\*.bw**: BigWig coverage files for genome browser visualization



## Configuration

### Nextflow Configuration

The `nextflow.config` file contains pipeline settings. Key sections:

**Docker Configuration:**
```groovy
docker.enabled = true
process.container = 'uschwartz/core_docker:v2.0'
docker.runOptions = '-u $(id -u):$(id -g)'
```

**Resource Configuration:**
```groovy
process {
    withLabel: big_mem {
        cpus = 12
        memory = 50.GB
        queue = 'long'
    }
    withLabel: mid_mem {
        cpus = 6
        memory = 25.GB
        queue = 'long'
    }
}
```

### Running on HPC/Cloud

For HPC or cloud execution, create a custom configuration:

```bash
# Create custom config
cat > custom.config <<EOF
process {
    executor = 'slurm'
    queue = 'compute'
    memory = '32 GB'
    cpus = 8
    time = '24h'
}
EOF

# Run with custom config
nextflow run RNAseq_NAC -c custom.config [other parameters]
```

See the [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for executor-specific configurations.



### Tools Included (via Docker)

The `uschwartz/core_docker:v2.0` container includes:
- **FastQC**: Quality control for sequencing data
- **MultiQC**: Aggregates QC reports
- **Trim Galore**: Adapter trimming wrapper
- **STAR**: Spliced aligner for RNA-seq
- **Samtools**: BAM file manipulation
- **Picard**: Duplicate marking and metrics
- **Qualimap**: RNA-seq specific QC
- **dupRadar**: Duplication rate analysis
- **Subread (featureCounts)**: Gene expression quantification
- **deepTools**: BigWig generation

## Citation

If you use this pipeline in your research, please cite:

**Wernig-Zorc et al., 2023**  
*nucMACC: An optimized MNase-seq pipeline measures genome-wide nucleosome accessibility and stability*  
bioRxiv  
https://doi.org/10.1101/2022.12.29.521985

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

**Uwe Schwartz**  
📧 Email: uwe.schwartz@ur.de  
🔬 Institution: University of Regensburg

For bug reports and feature requests, please use the [GitHub Issues](https://github.com/uschwartz/RNAseq_NAC/issues) page.

## Acknowledgments

- Built with [Nextflow](https://www.nextflow.io/)
- Containerized with [Docker](https://www.docker.com/)
- Inspired by the bioinformatics community [nf-core](https://www.nf-co.re)

---

**Version:** 2.0.0  
**Last Updated:** February 2026
