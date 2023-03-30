

include{trimGalore_pe} from '../modules/trim'
include{star} from '../modules/STARalign'
include{makeBigWigs} from '../modules/makeBigWigs'
include{markDuplicates;bam_idx} from '../modules/markDuplicates'
include{qualimap} from '../modules/qualimap'
include{dupRadar} from '../modules/dupradar'
include{countReads} from '../modules/countReads'

workflow trim_pe{
        take:
        pair_in

        main:
        trimGalore_pe(pair_in)

        emit:
        trimGalore_pe.out[0]
        trimGalore_pe.out[1]
        trimGalore_pe.out[2]

}

workflow align{
        take:
        fastq_in
        gtf_ch
        gsize_ch

        main:
        star(fastq_in)
        if(!params.testRUN){
                makeBigWigs(star.out[1].flatten().combine(gsize_ch))
        }
        markDuplicates(star.out[0])
        bam_idx(markDuplicates.out[0])
        qualimap(bam_idx.out[0].combine(gtf_ch))
        dupRadar(bam_idx.out[0].combine(gtf_ch))
        countReads(markDuplicates.out[0].flatMap {
                logs, bams -> bams
                }.collect().ifEmpty([]),gtf_ch)


        emit:
        star.out[0]
        star.out[2]
        qualimap.out[0]
        countReads.out
}
