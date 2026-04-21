#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// ──────────────────────────────────────────────
//  Bacterial Genomics Pipeline
//  fastp -> skesa -> (mlst + fastani) in parallel
// ──────────────────────────────────────────────

// Params – defaults to test data
params.reads     = "${projectDir}/test_data/*_{1,2}.fastq.gz"
params.reference = "${projectDir}/test_data/reference.fna"
params.outdir    = "${launchDir}/results"

include { FASTP   } from './modules/fastp'
include { SKESA   } from './modules/skesa'
include { MLST    } from './modules/mlst'
include { FASTANI } from './modules/fastani'

// Workflow
workflow {

    // Create channel of paired-end reads
    reads_ch = Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .map { sample_id, files ->
            def meta = [id: sample_id]
            [ meta, files ]
        }

    // Load reference genome for FastANI
    ref_ch = Channel.fromPath(params.reference, checkIfExists: true)

    // Sequential: fastp -> skesa
    FASTP(reads_ch)
    SKESA(FASTP.out.reads)

    // ── Parallel: mlst + fastani on assembly ─ both use skesa output
    MLST(SKESA.out.assembly)
    FASTANI(SKESA.out.assembly, ref_ch.collect())
}
