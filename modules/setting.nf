/*
* Show settings at the beginning
*/

def settings() {
        println ''
         log.info """\

          R N A - s e q   P I P E L I N E
          =============================
          Path variables used in analysis
          reads : ${params.fastqPath}
          output : ${params.outPath}
          STARidx : ${params.STARidxPath}
          GTF.files : ${params.gtfPath}
          Name.Expression: ${params.exprName}


          General options
          pairedEnd : ${params.pairedEnd}
          strandness : ${params.strandness}
          GTFforCounting: ${params.gtfFile}
          Trimming: ${params.trim}


         """.stripIndent()

println ''
}
