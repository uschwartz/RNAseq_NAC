process countReads{
        label 'big_mem'
        publishDir "${params.outPath}/Counts/", mode: 'copy'

	input:
        file bams
        path(gtf)

	output:
        file "*.txt*"


        script:
        strandness_Map = ["unstranded": 0, "forward" : 1 , "reverse" : 2]

        stranded=strandness_Map[params.strandness]
        pairedOpt = ( params.pairedEnd ? '-p':'')
	"""
        featureCounts $pairedOpt -T $task.cpus -s $stranded  -a ${params.gtfPath}/${params.gtfFile} -o count_table.txt $bams &>count_info.txt
	"""
}
