/*
* Help message
*/

def helpMessage() {
        println ''
        log.info """
            R N A - s e q   P I P E L I N E
            =============================
            Usage:

            nextflow run RNAseq --fastqPath 'path2dirFASTQ' --outPath 'path2output'

            Mandatory arguments:
              --fastqPath           Path to fastq data (must end with .fastq.gz)
              --outPath             Path to write output
              --STARidxPath         Path to STAR index
              --gtfPath             Path to GTF files


            Generic:
              --pairedEnd           Specifiy if input is paired-end sequencing data (allowed: true/false; default: false)
              --strandness          Specifiy directionality of sequencing data (allowed: forward/reverse/unstranded; default: reverse)
              --testRUN             performs a test run of the first 100,000 reads of one sample (default false)
              --gtfFile             Name of GTF file for counting which is located in gtfPath (standard: protein_coding.gtf/all_genes.gtf/protein_coding_and_lincRNA.gtf ;default: protein_coding.gtf)
              --exprName            Expression used to look for fastq files of single end reads (default: '*.fastq.gz')
              --exprNamePE          Expression used to look for fastq files of paired end reads (default: '*{1,2}.fastq.gz')
              --highMemory          Specify if memory overflow in STAR (default: false)


            STAR:
              --zipSTAR             unzipping option used in STAR [default: gunzip]

            Trimming:
              --trim             enable adapter trimming (allowed: true/false; default: false)
              --adapters         Specify the path to the adapter sequence file in fasta format

        """.stripIndent()
        println ''
}
