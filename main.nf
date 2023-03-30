#!/usr/bin/env nextflow

 /*
 ===============================================================================
                      nextflow based RNAseq pipeline
 ===============================================================================
Authors:
Uwe Schwartz <uwe.schwartz@ur.de>
 -------------------------------------------------------------------------------
 */

nextflow.enable.dsl = 2

//                           show settings
if (!params.help) {
        include{settings} from './modules/setting'
        settings()
}

//                       help message
// Show help message
if (params.help) {
    include{helpMessage} from './modules/help'
    helpMessage()
    exit 0
}


// to set strandness for featureCounts and dupRadar
def strandness_Map = ["unstranded": 0, "forward" : 1 , "reverse" : 2]

/*
 * Create a channel for input read files
 */

if(params.testRUN){
        fastq_files=Channel.fromPath("${params.fastqPath}/${params.exprName}")
                .splitFastq(by: 10000, limit: 10000, file: true).first()
} else {
        fastq_files=Channel.fromPath("${params.fastqPath}/${params.exprName}")
}

// input for alignment
if(params.testRUN){
        fastq2align = ( params.pairedEnd
                        ? Channel.fromFilePairs("${params.fastqPath}/${params.exprNamePE}", flat:true).first()
                        .splitFastq(by: 10000_10000, limit: 10000 ,pe:true, file:true)
                        .map { filename,fwd,rev-> tuple(filename, [fwd,rev]) }
                      : Channel
                        .fromPath("${params.fastqPath}/${params.exprName}").first()
                        .map { file -> tuple(file.simpleName, file.splitFastq(by: 10000, limit: 10000, file: true))}
                        )
} else {
        fastq2align = ( params.pairedEnd
                      ? Channel.fromFilePairs("${params.fastqPath}/${params.exprNamePE}")
                      : Channel
                        .fromPath("${params.fastqPath}/${params.exprName}")
                        .map { file -> tuple(file.simpleName, file)}
                        )
}


//////////// STARidx annotation path ///////////////
Channel.fromPath(params.STARidxPath, type: 'dir')
       .set{idx_ch}

//////////// STARidx annotation path ///////////////
Channel.fromPath("${params.STARidxPath}/chrNameLength.txt")
              .set{gsize_ch}

//////////// Gene annotation path ///////////////
Channel.fromPath(params.gtfPath, type: 'dir')
      .set{gtf_ch}

// load modules

//fastqc
include{fastqc; multiqc as multiqc_raw;
        multiqc as multiqc_final} from './modules/raw_qc'

//workflow
include{trim_pe; align} from './workflows/paired'

workflow{
        fastqc(fastq_files)
        multiqc_raw(fastqc.out[0].collect())

        if(params.pairedEnd){
                if(params.trim){
                        trim_pe(fastq2align)

                        align(trim_pe.out[0].combine(idx_ch),gtf_ch, gsize_ch)

                        multiqc_final(fastqc.out[0].mix(trim_pe.out[1])
                        .mix(trim_pe.out[2]).mix(align.out[1])
                        .mix(align.out[3]).collect())

//align.out[2].collect().view()
                }

        } else {
                align(fastq2align.combine(idx_ch), gsize_ch)

                //multiqc_final(fastqc.out[0]
                //        .mix(align.out[1]).mix(align.out[2]).collect())
        }




}
