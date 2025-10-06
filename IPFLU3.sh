#!/bin/bash
#SBATCH --job-name=variantcalling
#SBATCH --partition=batch
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=168:00:00
#SBATCH --mem=50gb
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jms71286@uga.edu

cd ./scratch/jms71286/IPFLU

IPFLU_out="/scratch/jms71286/IPFLU"

module load SAMtools/1.21-GCC-13.3.0
module load BCFtools/1.21-GCC-13.3.0  #L16 Slide 11


bcftools mpileup -Oz --threads 6 --min-MQ 40 -f $IPFLU_out/Af293_refseq_genomic.fna.gz $IPFLU_out/eAF2436.bam > $IPFLU_out/eAF2436.mpileup.vcf.gz   #Generates genotype likelihoods at variant sites

bcftools call -Oz -mv --threads 6 --ploidy 1 $IPFLU_out/eAF2436.mpileup.vcf.gz > $IPFLU_out/eAF2436.mpileup.call.vcf.gz   #Calls variants

bcftools filter -Oz -e 'QUAL<40 || DP<10' $IPFLU_out/eAF2436.mpileup.call.vcf.gz > $IPFLU_out/eAF2436.mpileup.call.filter.vcf.gz

bcftools index $IPFLU_out/eAF2436.mpileup.call.filter.vcf.gz # vcf.gz.csi file - allows quick access to the zipped vcf file

gunzip -c $IPFLU_out/eAF2436.mpileup.call.filter.vcf.gz > $IPFLU_out/eAF2436.mpileup.call.filter.vcf


# bcftools consensus -f $HW4_OUTDIR/MG1655_RefSeq.fna $HW4_OUTDIR/SRR8082143.sorted.mpileup.call.filter.vcf.gz > $HW4_OUTDIR/SRR8082143_consensus.fa
