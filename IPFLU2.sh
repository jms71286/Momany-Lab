#!/bin/bash
#SBATCH --job-name=indexref
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=168:00:00
#SBATCH --mem=50gb
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jms71286@uga.edu

cd ./scratch/jms71286/IPFLU
module load BWA/0.7.18-GCCcore-13.3.0

IPFLU_out="/scratch/jms71286/IPFLU" #ILLUMINA READS W SAMTOOLS AND BCFTOOLS

bwa index $IPFLU_out/Af293_Refseq_CDS.fna

module load SAMtools/1.21-GCC-13.3.0

for sample in *_1.fastq.gz
do
  i="${sample%%_1.fastq.gz}"
  input1="${i}_1.fastq.gz"
  input2="${i}_2.fastq.gz"
  output="${i}"

  bwa mem $IPFLU_out/Af293_Refseq_CDS.fna $IPFLU_out/25266-01-fastq/eAF2436_R1.fastq.gz $IPFLU_out/25266-01-fastq/eAF2436_R2.fastq.gz | samtools view -b - | samtools sort -o $IPFLU_out/eAF2436.bam -
done
