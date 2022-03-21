
Channel
      .fromPath(params.vcf_list)
      .ifEmpty { exit 1, "Cannot find input file : ${params.vcf_list}" }
      .splitCsv(skip:1)
      .map { row -> tuple(row[0], file(row[1]), file(row[2]))}
      .take( params.number_of_files_to_process )
      .set { vcf_input }

process bcftools_view {
	publishDir "${params.outdir}/head", mode: 'copy'

    echo true
	container = 'quay.io/lifebitai/bcftools:RE20-4857-IS-617-v5'
	containerOptions = '-v /etc/ssl:/etc/ssl -v /usr/local/share/ca-certificates:/usr/local/share/ca-certificates'

    input:
	tuple val(sampleID), val(vcf), val(index) from vcf_input

	output:
	file("${sampleID}_output.txt")

    script:
    """
    bcftools query -l s3:/${vcf} > ${sampleID}_output.txt
    """
}
