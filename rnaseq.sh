#!/bin/bash
#SBATCH --job-name=22july2024                            # Job name
#SBATCH --partition=batch		                             # Partition (queue) name
#SBATCH --ntasks=1			                                 # Single task job
#SBATCH --cpus-per-task=6 	                             # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=24gb			                                 # Total memory for job
#SBATCH --time=4:00:00  		                             # Time limit hrs:min:sec
#SBATCH --output=/home/jms71286/logs/log.%j			         # Standard output and error log - # replace with your myid
#SBATCH --mail-user=jms71286@uga.edu                     # Where to send mail - # replace cbergman with your myid
#SBATCH --mail-type=ALL                                  # Mail events (BEGIN, END, FAIL, ALL)

#Using Project_RNAseq.sh as template
#PROJ_OUTDIR="/work/gene8940/jms71286/Project_RNAseq"
rnaseq="/scratch/jms71286/22july2024"

if [ ! -d $rnaseq ]
then
    mkdir -p $rnaseq
fi

KALLISTO_OUTDIR="/scratch/jms71286/22july2024_results"

if [ ! -d $KALLISTO_OUTDIR ]
then
    mkdir -p $KALLISTO_OUTDIR
fi

curl -s https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/655/GCF_000002655.1_ASM265v1/GCF_000002655.1_ASM265v1_genomic.fna.gz  | gunzip -c > $rnaseq/Af293_refseq_CDS.fna

module load kallisto/0.44.0-foss-2022a
kallisto index -i $rnaseq/Af293_refseq_CDS.fa.idx $rnaseq/Af293_refseq_CDS.fna  #output_index input_fasta

kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR1813949 $rnaseq/SRR1813949_1.fastq.gz $rnaseq/SRR1813949_2.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR1813950 $rnaseq/SRR1813950_1.fastq.gz $rnaseq/SRR1813950_2.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR1816873 $rnaseq/SRR1816873_1.fastq.gz $rnaseq/SRR1816873_2.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR3190000 $rnaseq/SRR3190000_1.fastq.gz $rnaseq/SRR3190000_2.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR3190001 $rnaseq/SRR3190001_1.fastq.qz $rnaseq/SRR3190001_2.fastq.qz

conda activate R
R --no-save < /home/jms71286/Momany-Lab/rnaseq_R.r
