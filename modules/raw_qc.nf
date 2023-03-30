process fastqc{

  publishDir "${params.outPath}/QC/01_FastQC_rawData", mode: 'copy', pattern: "*.html"

  input:
  file(read)

  output:
  file "*_fastqc.zip"
  file "*_fastqc.html"
  file("*_fastqc.zip")

  script:
  """
  fastqc $read
  """
}

process multiqc{

  publishDir "${params.outPath}/QC/multiqc/", mode: 'copy'

  input:
  file('*')
  output:
  file "*multiqc_report.html"
  file "*_data"

  script:
  """
  multiqc .
  """
}
