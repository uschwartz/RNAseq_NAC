process makeBigWigs{
        publishDir "${params.outPath}/Alignment/profiles/unique/", mode: 'copy', pattern:"*.Unique.*"
        publishDir "${params.outPath}/Alignment/profiles/multiple/", mode: 'copy', pattern:"*.UniqueMultiple*"

        input:
        tuple file(wig), path(star2idx)

        output:
        file("*.bw")

        script:
        """
        wigToBigWig $wig ${params.STARidxPath}/chrNameLength.txt ${wig.baseName}.bw
        """
}
