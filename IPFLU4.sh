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

IPFLU_out="/scratch/jms71286/IPFLU" #ILLUMINA READS W BWA and SAMTOOLS

gunzip -c $IPFLU_out/eAF2436.mpileup.vcf.gz > $IPFLU_out/eAF2436.mpileup.vcf


module load BCFtools/1.21-GCC-13.3.0
module load seqtk/1.4-GCC-13.3.0


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



#time vcfutils.pl vcf2fq SRR850113.vcf > SRR850113.fq
#This filters all sequence so it is lower-case in the fasta format output file if it's phred-scaled quality is < Q40 (ie error rate is over 1 in 10,000 nucleotides):
#seqtk seq -q 40 -A SRR850113.fq > SRR850113.fa
#vcfutils.pl does not work on compressed vcf files (vcf.gz). If you have compressed vcfs, and you do not want to uncompress them, here is a solution:
#gunzip -c input.vcf.gz | vcfutils.pl vcf2fq - | seqtk seq -q 40 -A > output.fa
#This will create a fasta file, keeping the vcf.gz file unchanged. Running this will avoid creating a new uncompressed vcf (usually very large), and fq files.
