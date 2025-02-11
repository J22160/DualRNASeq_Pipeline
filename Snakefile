# ===================================================================================================
#                       DualRNASeq Pipeline Snakefile
# ===================================================================================================
# Author: Jash Trivedi
# Date: 12/19/2024
# Project: DualRNASeq Analysis Pipeline
#
# Description:
# This Snakefile is the central orchestrator for a DualRNASeq pipeline, designed 
# to process and analyze RNA sequencing data for host-pathogen interactions. The 
# pipeline consists of several steps including data acquisition, preprocessing, 
# alignment to host and pathogen genomes, quality control, contamination screening, 
# and gene quantification. The pipeline is modular, leveraging Snakemake's rules 
# and includes external configuration files for flexibility.
#
# Input:
# - Raw paired-end FASTQ files stored in the `data/` directory.
# - Configuration file (`config/config.yaml`) specifying parameters such as paths to 
#   reference genomes, annotation files, and other essential resources.
#
# Output:
# - Quality control reports for raw and trimmed reads.
# - Aligned BAM files for host and pathogen genomes and alignment quality control reports.
# - Gene count tables for both host and pathogen using HTSeq-count.
# - Comprehensive MultiQC report summarizing QC, alignment, and bacterial screening results.
#
# Rules:
# - `get_data.smk`: Automates the detection of input FASTQ files in the `data/` directory.
# - `preprocessing.smk`: Performs quality control and trimming of raw reads.
# - `alignment.smk`: Aligns reads to host and pathogen genomes.
# - `alignment_qc.smk`: Performs quality control of BAM files using Qualimap.
# - `kraken_screening.smk`: Screens for bacterial contamination using Kraken.
# - `multiqc.smk`: Aggregates all QC and alignment results into a single report.
# - `gene_quantification.smk`: Quantifies gene expression using HTSeq-count for host 
#   and pathogen genomes.
#
# Usage:
# - Modify the configuration file (`config/config.yaml`) as per project requirements.
# - Run the pipeline using the command:
#   `snakemake --sdm conda --cores <num_cores>` to execute on available cores.
# ====================================================================================================

#config file
configfile: "config/config.yaml"

# Include modular rules from respective Snakefiles
include: "rules/get_data.smk"
include: "rules/preprocessing.smk"
include: "rules/alignment.smk"
include: "rules/alignment_qc.smk"
include: "rules/kraken_screening.smk"
include: "rules/multiqc.smk"
include: "rules/gene_quantification.smk"

# Identify samples from input FASTQ files in the `data/` directory
samples = glob_wildcards("data/{sample}_1.fastq.gz")
sorted_samples = sorted(samples)
SAM = list(set(sorted_samples))


rule all:
    input:
        # Quality control reports for raw FASTQ files
        raw_read_quality_report_html_r1=expand("output/qc/{sample}_1_fastqc.html", sample=SAM),
        raw_read_quality_report_html_r2=expand("output/qc/{sample}_2_fastqc.html", sample=SAM),
        
        # Trimmed FASTQ files
        raw_read_trimming_r1=expand("output/trimmed_data/{sample}_1_trimmed.fastq.gz", sample=SAM),
        raw_read_trimming_r2=expand("output/trimmed_data/{sample}_2_trimmed.fastq.gz", sample=SAM),
        
        # Quality control reports for trimmed FASTQ files
        cleaned_data_fastqc_html_r1=expand("output/qc/trimmed/{sample}_1_fastqc.html", sample=SAM),
        cleaned_data_fastqc_html_r2=expand("output/qc/trimmed/{sample}_2_fastqc.html", sample=SAM),
        
        # Aligned BAM files for host genome
        host_alignment_bam=expand("output/alignment/mapped/host/{sample}_aligned.bam", sample=SAM),
        host_alignment_unmapped_r1=expand("output/alignment/unmapped/host/{sample}_unmapped1.fastq.gz", sample=SAM),
        host_alignment_unmapped_r2=expand("output/alignment/unmapped/host/{sample}_unmapped2.fastq.gz", sample=SAM),
        
        # Aligned BAM files for pathogen genome
        pathogen_alignment_bam=expand("output/alignment/mapped/pathogen/{sample}_aligned.bam", sample=SAM),
        pathogen_alignment_unmapped_r1=expand("output/alignment/unmapped/pathogen/{sample}_unmapped1.fastq.gz", sample=SAM),
        pathogen_alignment_unmapped_r2=expand("output/alignment/unmapped/pathogen/{sample}_unmapped2.fastq.gz", sample=SAM),
        
        # Alignment QC reports using Qualimap
        qualimap_qc_host=expand("output/alignment_qc/host/{sample}", sample=SAM),
        qualimap_qc_pathogen=expand("output/alignment_qc/pathogen/{sample}", sample=SAM),
        
        # Kraken screening reports
        kraken_screening_report=expand("output/bacterial_screening/kraken/{sample}_kraken_report.txt", sample=SAM),
        
        # Comprehensive MultiQC report
        multiqc_combined_report="output/multiqc/multiqc_combined_report.html",
        
        # Gene quantification tables
        host_gene_quantification="output/gene_count/host/host_gene_count.txt",
        pathogen_gene_quantification="output/gene_count/pathogen/pathogen_gene_count.txt"

