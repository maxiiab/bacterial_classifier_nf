process SKESA {
    conda "${projectDir}/envs/skesa.yml"

    publishDir "${params.outdir}/assemblies", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_assembly.fna"), emit: assembly

    script:
    """
    skesa \\
      --reads ${reads.join(',')}\\
      --cores ${task.cpus} \\
      --contigs_out ${meta.id}_assembly.fna
    """
}
