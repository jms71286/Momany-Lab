#!/bin/bash
#SBATCH --job-name=WGS	                                       # Job name
#SBATCH --partition=batch		                                   # Partition (queue) name
#SBATCH --ntasks=1			                                       # Single task job
#SBATCH --cpus-per-task=24 	                                   # Number of cores per task - match this to the num_threads used by BLAST
#SBATCH --mem=50gb			                                       # Total memory for job
#SBATCH --time=2:00:00  		                                   # Time limit hrs:min:sec	                             # Standard output and error log - #
#SBATCH --mail-user=jms71286@uga.edu                           # Mail events (BEGIN, END, FAIL, ALL)

#!/bin/bash
#SBATCH --job-name=indexref
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=8:00:00
#SBATCH --mem=8G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mmm07490@uga.edu

cd ./
module load BWA/0.7.18-GCCcore-13.3.0

bwa index /work/dblab/miranda/scripts/sacParRef.fna

# above is mirandaas

WGS="/scratch/jms71286/WGS" #ILLUMINA READS W SAMTOOLS AND BCFTOOLS

module load SRA-Toolkit/3.0.10-gompi-2023a
module load BWA/0.7.17-GCCcore-12.3.0
module load SAMtools/1.21-GCC-13.3.0

bwa index $WGS/GCF_000002655.1_ASM265v1_genomic.fna    # to make BWA index, L15 Slide 16
bwa mem -t 1 $WGS/GCF_000002655.1_ASM265v1_genomic.fna $WGS/CEA10_GCA_051225625.1_ASM5122562v1_genomic.fna > $WGS/CEA10.sam     #bwa mem -t 1 ref_genome.fa sample_1.fastq.gz sample_2.fastq.gz > sample.sam

samtools view $WGS/CEA10.sam -O BAM -o $WGS/CEA10.bam       # converts .sam format to .bam
samtools sort --threads 6 $WGS/CEA10.bam -o $WGS/CEA10.sorted.bam       # sorts .bam
samtools index $WGS/CEA10.sorted.bam         # generates index for sorted .bam
#everything above this line ran in interact and worked

module load BCFtools/1.21-GCC-13.3.0  #L16 Slide 11

bcftools mpileup -Oz --threads 6 --min-MQ 60 -f $WGS/GCF_000002655.1_ASM265v1_genomic.fna $WGS/CEA10.sorted.bam > $WGS/CEA10.sorted.mpileup.vcf.gz   #Calls genotype liklihoods
bcftools call -Oz -mv --threads 6 --ploidy 1 $WGS/CEA10.sorted.mpileup.vcf.gz > $WGS/CEA10.sorted.mpileup.call.vcf.gz   #Calls variants

bcftools filter -Oz -e 'QUAL<40 || DP<10' $WGS/CEA10.sorted.mpileup.call.vcf.gz > $WGS/CEA10.sorted.mpileup.call.filter.vcf.gz #Filters variants
bcftools index $WGS/CEA10.sorted.mpileup.call.filter.vcf.gz # vcf.gz.csi file - allows quick access to the zipped vcf file
gunzip -c $WGS/CEA10.sorted.mpileup.call.filter.vcf.gz > $WGS/UNZIP_CEA10.sorted.mpileup.call.filter.vcf

# bcftools consensus -f $HW4_OUTDIR/MG1655_RefSeq.fna $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz > $HW4_OUTDIR/SRR8082143_consensus.fa


$IPFLU/25266-01-fastq/eAF2436_R1.fastq.gz
$IPFLU/25266-01-fastq/eAF2436_R2.fastq.gz
$IPFLU/25266-01-fastq/AfDT96_R1.fastq.gz
$IPFLU/25266-01-fastq/AfDT96_R2.fastq.gz
$IPFLU/25266-01-fastq/AfDT109_R1.fastq.gz
$IPFLU/25266-01-fastq/AfDT109_R2.fastq.gz
$IPFLU/25266-01-fastq/AfDT101_R1.fastq.gz
$IPFLU/25266-01-fastq/AfDT101_R2.fastq.gz
