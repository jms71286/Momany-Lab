#!/bin/bash
#SBATCH --job-name=vcf to fasta
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
module load seqtk/1.4-GCC-13.3.0

gunzip -c $IPFLU_out/eAF2436.mpileup.vcf.gz > $IPFLU_out/eAF2436.mpileup.vcf

for file in *.vcf; do
        strain=${file%%.vcf};
        outputfa="${strain}.fa";
        echo "File: ${file}";
    echo "Strain: ${strain}";
    echo "Outputfa: ${outputfa}";
    pwd
    #echo "${strain}" > ${outputfa}.test;
    ./vcfutils.pl vcf2fq $IPFLU_out/eAF2436.mpileup.vcf | seqtk seq -q 40 -A > $IPFLU_out/eAF2436.mpileup.fa
done
