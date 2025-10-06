#!/bin/bash
#SBATCH --job-name=SnpEff
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=8:00:00
#SBATCH --mem=64gb
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jms71286@uga.edu

cd ./scratch/jms71286/IPFLU

IPFLU_out="/scratch/jms71286/IPFLU" #ILLUMINA READS W BWA and SAMTOOLS

# Download using wget
wget https://snpeff.odsp.astrazeneca.com/versions/snpEff_latest_core.zip

# If you prefer to use 'curl' instead of 'wget', you can type:
#     curl -L https://snpeff.odsp.astrazeneca.com/versions/snpEff_latest_core.zip > snpEff_latest_core.zip

# Install
unzip snpEff_latest_core.zip
