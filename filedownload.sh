#!/bin/bash
#SBATCH --job-name=rnaseq                           # Job name
#SBATCH --partition=batch		                             # Partition (queue) name
#SBATCH --ntasks=1			                                 # Single task job
#SBATCH --cpus-per-task=6 	                             # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=24gb			                                 # Total memory for job
#SBATCH --time=10:00:00  		                             # Time limit hrs:min:sec
#SBATCH --output=/home/jms71286/logs/log.%j			         # Standard output and error log - # replace with your myid
#SBATCH --mail-user=jms71286@uga.edu                     # Where to send mail - # replace cbergman with your myid
#SBATCH --mail-type=ALL                                  # Mail events (BEGIN, END, FAIL, ALL)

#Using Project_RNAseq.sh as template
#PROJ_OUTDIR="/work/gene8940/jms71286/Project_RNAseq"
rnaseq="/scratch/jms71286/rnaseq"

if [ ! -d $rnaseq ]
then
    mkdir -p $rnaseq
fi

KALLISTO_OUTDIR="/scratch/jms71286/rnaseq_results"

if [ ! -d $KALLISTO_OUTDIR ]
then
    mkdir -p $KALLISTO_OUTDIR
fi

module load SRA-Toolkit/3.0.1-centos_linux64
module load BWA/0.7.17-GCCcore-11.2.0
module load SAMtools/1.10-GCC-8.3.0

#download af293 whole genome seq
curl -s https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/655/GCF_000002655.1_ASM265v1/GCF_000002655.1_ASM265v1_genomic.fna.gz  | gunzip -c > $rnaseq/Af293_refseq_CDS.fna
#download rnaseq gz sra files
curl -s ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR181/000/SRR1813950/SRR1813950.fastq.gz | gunzip -c > $rnaseq/SRR1813950.fastq.gz #WT2
curl -s ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR319/000/SRR3190000/SRR3190000.fastq.gz | gunzip -c > $rnaseq/SRR3190000.fastq.gz #veA delete3
curl -s ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR319/001/SRR3190001/SRR3190001.fastq.gz | gunzip -c > $rnaseq/SRR3190001.fastq.gz #veA delete4

#prefetch -O $rnaseq SRR1813950  #prefetch -O /work/gene8940/cbergman/ SRR8082143 WT2
#fastq-dump --split-files --gzip $rnaseq/SRR1813950.sra -O $rnaseq

#prefetch -O $rnaseq SRR3190000  #prefetch -O /work/gene8940/cbergman/ SRR8082143 veA delete3
#fastq-dump --split-files --gzip $rnaseq/SRR3190000.sra -O $rnaseq
#prefetch -O $rnaseq SRR3190001  #prefetch -O /work/gene8940/cbergman/ SRR8082143 veA delete4
#fastq-dump --split-files --gzip $rnaseq/SRR3190001.sra -O $rnaseq

bwa index $rnaseq/Af293_refseq_CDS.fna       # to make BWA index, L15 Slide 16
bwa mem -t 6 $rnaseq/Af293_refseq_CDS.fna $rnaseq/SRR1813950_1.fastq.gz $rnaseq/SRR1813950_2.fastq.gz > $rnaseq/SRR1813950.sam     # bwa mem -t 1 ref_genome.fa sample_1.fastq.gz sample_2.fastq.gz > sample.sam

#samtools view $rnaseq/SRR1813950.sam -O BAM -o $rnaseq/SRR1813950.bam       # converts .sam format to .bam
#samtools sort --threads 6 $rnaseq/SRR1813950.bam -o $rnaseq/SRR1813950.sorted.bam       # sorts .bam
#samtools index $rnaseq/SRR1813950.sorted.bam          # generates index for sorted .bam

module load kallisto/0.44.0-foss-2022a
kallisto index -i $rnaseq/Af293_refseq_CDS.fa.idx $rnaseq/Af293_refseq_CDS.fna  #output_index input_fasta

kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR1813950 $rnaseq/SRR1813950.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR3190000 $rnaseq/SRR3190000.fastq.gz
kallisto quant -t 6 -b 100 -i $rnaseq/Af293_refseq_CDS.fa.idx -o $KALLISTO_OUTDIR/SRR3190001 $rnaseq/SRR3190001.fastq.qz 
