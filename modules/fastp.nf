process FASTP {
    conda "${projectDir}/envs/fastp.yml"

    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_trimmed_{1,2}.fastq.gz"), emit: reads
    path("${meta.id}.fastp.{json,html}"),                       emit: reports

    script:
    """
    fastp \\
      -i ${reads[0]} \\
      -I ${reads[1]} \\
      -o ${meta.id}_trimmed_1.fastq.gz \\
      -O ${meta.id}_trimmed_2.fastq.gz \\
      -h ${meta.id}.fastp.html \\
      -j ${meta.id}.fastp.json \\
      --thread ${task.cpus}
    """
}
