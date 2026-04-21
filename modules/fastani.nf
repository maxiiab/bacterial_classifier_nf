process FASTANI {
    conda "${projectDir}/envs/fastani.yml"

    publishDir "${params.outdir}/fastani", mode: 'copy'

    input:
    tuple val(meta), path(assembly)
    path(reference)

    output:
    path("${meta.id}_fastani.tsv"), emit: results

    script:
    """
    fastANI \\
      --query ${assembly} \\
      --ref ${reference} \\
      --output ${meta.id}_fastani.tsv
    """
}
