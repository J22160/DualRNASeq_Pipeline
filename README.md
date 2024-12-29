# DualRNASeq Analysis Pipeline  

### Author: Jash Trivedi, MS Biotechnology, University of Central Florida  

---  

## **Overview**  

The DualRNASeq Analysis Pipeline is a robust bioinformatics workflow designed for the analysis of host-pathogen dual RNA sequencing (DualRNASeq) data. This pipeline processes paired-end RNA-Seq data to explore transcriptional responses in host and pathogen during infection. The workflow covers essential steps including preprocessing, alignment, contamination screening, quality control, and gene quantification. This pipeline integrates host and pathogen RNA-Seq data in a single workflow, enabling simultaneous analysis of dual transcriptional responses. Unlike traditional RNA-Seq pipelines, it includes host-pathogen interaction-specific steps such as metagenomic classification (Kraken2) and pangenomic expression analysis for bacterial strains. 

With a modular structure, the pipeline ensures flexibility and scalability, allowing users to adapt it to their specific projects. Each module is implemented as a separate [snakemake](https://snakemake.readthedocs.io/en/stable/) rules for ease of maintenance and debugging, and configurations are centralized in a single [`config.yaml`](https://github.com/J22160/DualRNASeq_Pipeline/blob/b02be676643d741524527d47548fb255172ccb6f/configs/config.yaml) file.  

This pipeline has been effectively utilized in a serotype 3 *Streptococcus pneumoniae* (SPN) project aimed at unraveling the complexities of host-pathogen interactions during infection. By analyzing dual RNA-Seq data from mice infected with clade I and clade II strains of serotype 3 SPN, the study identified distinct transcriptional responses in both the host and pathogen. The investigation revealed critical insights into the expression of accessory genes, patterns of transcriptional dysregulation, and clade-specific virulence factors, providing a deeper and more nuanced understanding of SPN pathogenicity.  

---  

## **Key Features**  

- **Flexible Input Handling**: Automatically detects paired-end FASTQ files in the data directory.  
- **Data Preprocessing**: Includes trimming of low-quality reads and adapters using `fastp`.  
- **Alignment**: Supports alignment to both host reference genome and pathogen pangenomes using `STAR & Bowtie2`.  
- **Contamination Screening**: Screens unmapped reads from host for identifying any bacterial reads using `Kraken2` & `blast`.  
- **Quality Control**: Performs quality checks using `FastQC` and `Qualimap`, with summary reports generated by `MultiQC`.  
- **Gene Quantification**: Quantifies gene expression levels using `htseq-count` for both host and pathogen.  
- **Benchmarking**: Tracks runtime and resource usage for each pipeline rule, aiding in optimization.  
- **Comprehensive Reporting**: Combines all QC and analysis outputs into a single MultiQC report.  

---  

## **Dual-RNASeq Pipeline Workflow**  

![alt text](https://github.com/J22160/RGENE/blob/ded5b0f9fd0707e31234291c1fc6e42387113883/snakemakeworkflow.png)


---

## **Setup and Usage**

### **1. Prerequisites**  
- `Snakemake`  
- `Conda` (for environment management)  

### **2. Clone the Repository**  
```bash  
git clone https://github.com/J22160/DualRNASeq_Pipeline.git   
```  

### **3. Run the `setup.sh` Script**  
Execute the setup script to install `Snakemake` and its dependencies, and to download and configure the Kraken2 database:  
```bash
chmod +x setup.sh  
bash setup.sh  
```  

The script performs the following:  

1. Configures a Conda environment for Snakemake.  
2. Installs Snakemake and its dependencies into the environment.  

### **4. Download the Kraken2 Database for Bacterial Pathogen Screening**  
To ensure accurate bacterial pathogen screening, download the Kraken2 database using the following commands:  
```bash
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20240605.tar.gz  
tar xzf k2_standard_08gb_20240605.tar.gz  
rm k2_standard_08gb_20240605.tar.gz  # Remove the compressed file after extraction
```  
- **Source:** This database is provided by the Kraken2 team and is hosted on Amazon S3.  
- **Purpose:** The Kraken2 database enables highly efficient and accurate taxonomic classification of metagenomic reads, aiding in bacterial pathogen screening. The database contains standard references optimized for microbiological studies and integrates seamlessly with the pipeline.  

After extracting the database, **update the `kraken2` directory path in `configs/config.yaml`** to point to the location where the database is saved. For example:  
```yaml
kraken2_db: /path/to/extracted/kraken2/database
```  
### **5. Configure the Pipeline**  
Edit the `configs/config.yaml` file to specify:  
- Paths to input data, reference files, and specific parameters for sequence alignment and gene quantification.  

### **6. Execute the Pipeline**

The DualRNASeq pipeline can be executed on a variety of platforms, including local machines, high-performance computing (HPC) environments, and cloud-based platforms. Below are detailed instructions for running the pipeline in different scenarios, as well as the steps for performing a dry run to validate the workflow.

#### **6.1. Perform a Dry Run (Optional but Recommended)**  
Before executing the pipeline, it is recommended to perform a dry run to verify the workflow without executing any tasks. This ensures that all dependencies, file paths, and configurations are correct.  
Run the following command:  
```bash  
snakemake --use-conda --cores <number_of_cores> -n  
```  
**Why is a dry run useful?**  
- Validates the workflow configuration and rules.
- Detects missing input files or incorrect paths.
- Prevents unnecessary execution errors, saving time and resources.

---

#### **6.2. Running the Pipeline Locally**  
To execute the pipeline on a local machine, use the following command:  
```bash  
snakemake --sdm conda --cores <number_of_cores>  
```  
Replace `<number_of_cores>` with the number of CPU cores you wish to allocate.

---

#### **6.3. Running on an HPC Cluster**  
For HPC environments, submit the pipeline as a job using a workload manager like Slurm. Here is an example Slurm submission script:

```bash  
#!/bin/bash
#SBATCH --job-name=dualrnaseq
#SBATCH --output=logs/dualrnaseq_%j.log
#SBATCH --error=logs/dualrnaseq_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=24:00:00
#SBATCH --partition=compute

module load conda
conda activate dualrnaseq_env

salloc -c 16 snakemake --sdm conda --cores $SLURM_NTASKS
```
Submit the script using:  
```bash  
sbatch <script_name>.sh  
```

---

#### **6.4. Running on a Cloud Platform**  
On a cloud-based platform, such as AWS or Google Cloud, ensure that a virtual machine or instance is configured with the required resources (e.g., CPU, memory, disk space). Install Conda and the pipeline dependencies, then execute:  
```bash  
snakemake --sdm conda --cores <number_of_cores>  
```  
Alternatively, use a managed HPC service like AWS Batch or Google Cloud Batch with containerized workflows.

---

#### **6.5. Additional Execution Options**  
- **Resume from an Interrupted Run:**  
  Use the `--rerun-incomplete` flag to resume from where the pipeline stopped:  
  ```bash  
  snakemake --sdm conda --cores <number_of_cores> --rerun-incomplete  
  ```  

- **Cluster Execution:**  
  Use the `--cluster` flag to submit jobs dynamically to a cluster:  
  ```bash  
  snakemake --sdm conda --cores <number_of_cores> --cluster "sbatch --partition=compute --time=24:00:00"  
  ```

- **Generate a DAG Visualization:**  
  Create a Directed Acyclic Graph (DAG) of the pipeline for visualization:  
  ```bash  
  snakemake --dag | dot -Tpng > dag.png  
  ```

These flexible options ensure compatibility across different computing environments, allowing seamless execution of the pipeline in local, HPC, or cloud-based setups.

---  

## **Benchmarking**  

Each rule in the pipeline incorporates Snakemake’s `benchmark` feature, allowing runtime and resource usage to be tracked in `.txt` files stored in the `output/benchmarks/` directory. These files provide critical information for performance tuning and optimization.  

---  

## **Memory Allocation Optimization**  

Memory usage can vary depending on the size of your input data. To optimize performance:  

1. Edit the `config/config.yaml` file and adjust the `mem_mb` parameter for specific rules.  
2. Use benchmarking results to identify rules requiring additional memory or compute resources.  

---  

## **Directory Structure**  

```plaintext  
project_root/
├── config/                        # Configuration files
│   └── config.yaml                # Centralized configuration file
├── data/                          # Input data (raw FASTQ files)
├── references/                    # Reference genome and annotation files
├── rules/                         # Individual Snakefiles for pipeline steps
│   ├── get_data.smk
│   ├── preprocessing.smk
│   ├── alignment.smk
│   ├── alignment_qc.smk
│   ├── kraken_screening.smk
│   ├── gene_quantification.smk
│   └── multiqc.smk
├── environments/                  # Conda environments for reproducibility
│   ├── fastqc.yaml
│   ├── fastp.yaml
│   ├── star.yaml
│   ├── bowtie2.yaml
│   ├── multiqc.yaml
│   ├── kraken2.yaml
│   ├── htseq-count.yaml
│   └── qualimap.yaml
|
└── Snakefile                      # Main pipeline file

```  

---  

## **Contact Information**  

For questions or support, please contact:  
**Jash Trivedi**  
- Email: jashtrivedi221@gmail.com  
- GitHub: [J22160](https://github.com/J22160)  
- LinkedIn: [Jash Trivedi](https://www.linkedin.com/in/jash-trivedi-25b358191/)
---  

## **Acknowledgments**  

This pipeline incorporates multiple open-source tools and is made possible by the contributions of the bioinformatics community. Special thanks to the developers of Snakemake and the individual tools used in this workflow.  

---
```