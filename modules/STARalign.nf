process star{
          label 'big_mem'

          publishDir "${params.outPath}/QC/04_mapping_reports", mode: 'copy', pattern: "*.final.out"
          input:
          tuple val(nameID), file(reads), path(star2idx)

          output:
          tuple val(nameID), file("*.bam")
          tuple file("*.wig")
          file "*.final.out"

          script:
          readFilesCmd=(params.testRUN & !params.trim ? '' :"--readFilesCommand $params.zipSTAR -c")
          stranded = ( params.strandness=="unstranded" ? '--outWigStrand Unstranded':'')
          """
          STAR --outFilterType BySJout \\
                --outFilterMultimapNmax 20 \\
                --alignSJoverhangMin 8 \\
                --alignSJDBoverhangMin 1 \\
                --outFilterMismatchNmax 999 \\
                --alignIntronMin 20 \\
                --alignIntronMax 1000000 \\
                --outFilterMismatchNoverReadLmax 0.04 \\
                --runThreadN $task.cpus \\
                --outSAMtype BAM SortedByCoordinate \\
                --outWigType wiggle $stranded \\
                --outSAMmultNmax 1 \\
                --outMultimapperOrder Random  $readFilesCmd \\
                --genomeDir $params.STARidxPath \\
                --readFilesIn  $reads \\
                --outFileNamePrefix $nameID"_" \\
                --limitBAMsortRAM ${task.memory.bytes}


          """

        }
