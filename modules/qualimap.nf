process qualimap{
        container 'quay.io/biocontainers/qualimap:2.2.2d--1'
        label 'mid_mem'
        publishDir "${params.outPath}/QC/05_qualimap/", mode: 'copy'

	input:
	tuple val(nameID), file(bam_file),file(bam_idx), path(gtf)

	output:
        path("${nameID}/*", type: 'dir')

        script:
        pairedOpt = ( params.pairedEnd ? '-pe':'')
	"""
	qualimap rnaseq --java-mem-size=${task.memory.giga}G -a uniquely-mapped-reads -bam $bam_file -gtf ${params.gtfPath}/protein_coding.gtf -outdir ${nameID} $pairedOpt
	"""
}
