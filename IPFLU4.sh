#!/bin/bash
#SBATCH --job-name=vcf2fasta
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=8:00:00
#SBATCH --mem=64gb
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jms71286@uga.edu

cd ./scratch/jms71286/IPFLU

IPFLU_out="/scratch/jms71286/IPFLU"


module load BCFtools/1.21-GCC-13.3.0

    bcftools consensus -f $IPFLU_out/Af293_refseq_genomic.fna $IPFLU_out/eAF2436.mpileup.call.filter.vcf.gz > eAF2436_consensus.fasta
