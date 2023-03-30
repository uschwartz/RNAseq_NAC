
process dupRadar{
        container 'quay.io/biocontainers/bioconductor-dupradar:1.28.0--r42hdfd78af_0'
        publishDir "${params.outPath}/QC/06_dupRadar/${nameID}", mode: 'copy'

	input:
	tuple val(nameID), file(bam_file),file(bam_idx), path(gtf)


	output:
        file "*{pdf,txt}"


        script:
        // to set strandness for featureCounts and dupRadar
        strandness_Map = ["unstranded": 0, "forward" : 1 , "reverse" : 2]

        stranded=strandness_Map[params.strandness]
        pairDup=( params.pairedEnd ? 'TRUE':'FALSE')
	"""
        dupRadar_script.R $bam_file ${params.gtfPath}/protein_coding.gtf $stranded $pairDup
	"""
}
