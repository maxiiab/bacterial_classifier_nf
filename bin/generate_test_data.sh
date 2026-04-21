#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
#  Generate mini test data for the pipeline
#
#  Uses E. coli K-12 MG1655 WGS accession ERR022075
#    ~28M paired-end spots → uses fastq-dump -X to grab only first 500k
#  Reference: E. coli K-12 MG1655 (GCF_000005845.2)
# ──────────────────────────────────────────────

ACCESSION="ERR022075"
READS_TO_GRAB=500000
ENV_NAME="testdata_fetch"

# ── Create and activate a temporary conda env ──
echo "Setting up conda env '${ENV_NAME}'"
conda create -n "${ENV_NAME}" -c bioconda -c conda-forge sra-tools pigz -y
eval "$(conda shell.bash hook)"
conda activate "${ENV_NAME}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="${REPO_DIR}/test_data"

mkdir -pv "$TEST_DIR"
cd "$TEST_DIR"

echo "Step 1: Downloading first ${READS_TO_GRAB} read pairs from ${ACCESSION}"
fastq-dump \
  --split-files \
  --skip-technical \
  -X "${READS_TO_GRAB}" \
  --outdir . \
  "${ACCESSION}"

echo "=== Step 2: Compressing ==="
pigz -9f "${ACCESSION}_1.fastq" "${ACCESSION}_2.fastq"

# Renaming for pipeline
mv -v "${ACCESSION}_1.fastq.gz" ecoli_1.fastq.gz
mv -v "${ACCESSION}_2.fastq.gz" ecoli_2.fastq.gz

echo "=== Step 4: Downloading reference genome ==="
curl -O https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip -f GCF_000005845.2_ASM584v2_genomic.fna.gz
mv -v GCF_000005845.2_ASM584v2_genomic.fna reference.fna

echo ""
echo "test_data/ contents:"
ls -lh "$TEST_DIR"
echo ""

# ── Clean up temporary conda env ──
conda deactivate
conda remove -n "${ENV_NAME}" --all -y
echo "Removed temporary conda env '${ENV_NAME}'."