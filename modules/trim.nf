process trimGalore_pe{
        label 'big_mem'
        publishDir "${params.outPath}/QC/02_TRIMMING/${sampleID}", mode: 'copy', pattern: "*trimming_report.txt"
        publishDir "${params.outPath}/QC/03_TRIMMED_FASTQC/${sampleID}", mode: 'copy', pattern: "*.html"

        input:
        tuple val(sampleID), file(reads)

        output:
        tuple val(sampleID), file("*.fq.gz")
        file "*trimming_report.txt"
        file "*_fastqc.zip"
        file "*_fastqc.html"
        tuple val(sampleID), file("*_fastqc.zip")

        script:
        """
        trim_galore --gzip \
         --paired \
         --cores $task.cpus \
         --fastqc \
         -q 1 \
         --stringency 3 \
         $reads

         rename 's/_val_/_trimmed_/' *_val_*
         """
}
