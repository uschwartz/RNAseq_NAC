process markDuplicates{
        container 'quay.io/biocontainers/picard:2.27.4--hdfd78af_0'
        label 'mid_mem'
        errorStrategy 'retry'
        maxRetries 5
        publishDir "${params.outPath}/Alignment/bam", mode: 'copy', pattern:"*_dupmark.bam*"

        input:
        tuple val(nameID), file(bam_file)

        output:
        tuple val(nameID),file("*_dupmark.bam")
        file "*_dupstats.txt" 



        script:
        """
        picard -Xmx${task.memory.giga}g MarkDuplicates \\
         M=${nameID}_dupstats.txt \\
         I=$bam_file \\
         O=${nameID}_dupmark.bam \\
         REMOVE_DUPLICATES=FALSE \\
         OPTICAL_DUPLICATE_PIXEL_DISTANCE=0

        """
}

process bam_idx{
        publishDir "${params.outPath}/Alignment/bam", mode: 'copy', pattern:"*_dupmark.bam*"

        input:
        tuple val(nameID), file(bam_file)
        output:
        tuple val(nameID), file(bam_file),file("*_dupmark.bam.bai")

        script:
        """
        samtools index ${nameID}_dupmark.bam
        """
}
