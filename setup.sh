#!/bin/bash

# =========================================================================================================
#                               DualRNASeq Pipeline Setup Script
#
# Author: Jash Trivedi
# Description: This script installs Snakemake and its dependencies within a conda environment 
# for running the DualRNASeq pipeline. It also downloads and sets up the Kraken2 database.
# =========================================================================================================

#Exit on Error
set -euo pipefail

# colors for output messages
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}Starting setup for DualRNASeq pipeline...${NC}"

# Check if Conda is installed
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Error: Conda is not installed. Please install Miniconda or Anaconda first.${NC}"
    exit 1
fi

# Create a new conda environment for the pipeline
echo -e "${YELLOW}Creating a conda environment for the DualRNASeq pipeline...${NC}"

conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

echo -e "${YELLOW}Installing Snakemake and essential dependencies...${NC}"

conda create --name dualrnaseq_env snakemake -y
source activate dualrnaseq_env

  
# Verify Snakemake installation
echo -e "${YELLOW}Verifying Snakemake installation...${NC}"
snakemake --version && echo -e "${GREEN}Snakemake installed successfully.${NC}"


# Step 5: Setup complete
echo -e "${GREEN}Setup complete! The environment is ready for the DualRNASeq pipeline.${NC}"
echo -e "${YELLOW}To activate the environment, run:${NC} conda activate dualrnaseq_env"


