process MLST {
    conda "${projectDir}/envs/mlst.yml"

    publishDir "${params.outdir}/mlst", mode: 'copy'

    input:
    tuple val(meta), path(assembly)

    output:
    path("${meta.id}_mlst.tsv"), emit: results

    script:
    """
    mlst ${assembly} > ${meta.id}_mlst.tsv
    """
}
