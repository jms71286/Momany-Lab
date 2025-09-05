#!/bin/bash
#SBATCH --job-name=homework_4		                               # Job name
#SBATCH --partition=batch		                                   # Partition (queue) name
#SBATCH --ntasks=1			                                       # Single task job
#SBATCH --cpus-per-task=6 	                                   # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=24gb			                                       # Total memory for job
#SBATCH --time=2:00:00  		                                   # Time limit hrs:min:sec
#SBATCH --output=/work/gene8940/jms71286/log.%j			           # Standard output and error log - # replace cbergman with your myid
#SBATCH --mail-user=jms71286@uga.edu                           # Where to send mail - # replace cbergman with your myid
#SBATCH --mail-type=ALL                                        # Mail events (BEGIN, END, FAIL, ALL)

HW4_OUTDIR="/work/gene8940/jms71286/homework_4" #ILLUMINA READS W SAMTOOLS AND BCFTOOLS

if [ ! -d $HW4_OUTDIR ]
then
    mkdir -p $HW4_OUTDIR
fi

module load SRA-Toolkit/2.9.6-1-centos_linux64
module load BWA/0.7.17-GCC-8.3.0
module load SAMtools/1.10-GCC-8.3.0

prefetch -O $HW4_OUTDIR SRR8082143  #prefetch -O /work/gene8940/cbergman/ SRR8082143
fastq-dump --split-files --gzip $HW4_OUTDIR/SRR8082143.sra -O $HW4_OUTDIR

curl -s https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz | gunzip -c > $HW4_OUTDIR/MG1655_RefSeq.fna

bwa index $HW4_OUTDIR/MG1655_RefSeq.fna       # to make BWA index, L15 Slide 16
bwa mem -t 6 $HW4_OUTDIR/MG1655_RefSeq.fna $HW4_OUTDIR/SRR8082143_1.fastq.gz $HW4_OUTDIR/SRR8082143_2.fastq.gz > $HW4_OUTDIR/SRR8082143.sam     # bwa mem -t 1 ref_genome.fa sample_1.fastq.gz sample_2.fastq.gz > sample.sam

samtools view $HW4_OUTDIR/SRR8082143.sam -O BAM -o $HW4_OUTDIR/SRR8082143.bam       # converts .sam format to .bam
samtools sort --threads 6 $HW4_OUTDIR/SRR8082143.bam -o $HW4_OUTDIR/SRR8082143.sorted.bam       # sorts .bam
samtools index $HW4_OUTDIR/SRR8082143.sorted.bam          # generates index for sorted .bam

module load BCFtools/1.10.2-GCC-8.3.0  #L16 Slide 11

bcftools mpileup -Oz --threads 6 --min-MQ 60 -f $HW4_OUTDIR/MG1655_RefSeq.fna $HW4_OUTDIR/SRR8082143.sorted.bam > $HW4_OUTDIR/SRR8082143.sorted.mpileup.vcf.gz   #Calls genotype liklihoods
bcftools call -Oz -mv --threads 6 --ploidy 1 $HW4_OUTDIR/SRR8082143.sorted.mpileup.vcf.gz > $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.vcf.gz   #Calls variants
bcftools filter -Oz -e 'QUAL<40 || DP<10' $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.vcf.gz > $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz #Filters variants
bcftools index $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz # vcf.gz.csi file - allows quick access to the zipped vcf file
gunzip -c $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz > $HW4_OUTDIR/UNZIP_SRR8082143.sorted.mpileup.call.filter.vcf

# bcftools consensus -f $HW4_OUTDIR/MG1655_RefSeq.fna $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz > $HW4_OUTDIR/SRR8082143_consensus.fa
