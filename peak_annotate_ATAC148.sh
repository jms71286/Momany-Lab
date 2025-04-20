#!/bin/bash
#SBATCH --job-name=peak_annotations
#SBATCH --partition=batch
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jms71286@uga.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50gb
#SBATCH --time=1:00:00
#SBATCH --output=../logs/heatmap.%j.out
#SBATCH --error=../logs/heatmap.%j.err

ATAC="/scratch/jms71286/ATACseq"
genome_gff="/scratch/jms71286/ATACseq/Genome/A1163_edit6_liftoff.gff"
peaks="/scratch/jms71286/ATACseq/Peaks1"
gDNA_N4="148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz_summits.bed"
N9_37="148-N9_ATAC_H1green_37C_3d__Rep1_S105_L003_R1_001_val_1.fq.gz_summits.bed"
N18_50="148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz_summits.bed"
N13_37="148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz_summits.bed"
N11_50="148-N11_ATAC_H1green_50C_3d__Rep1_S107_L003_R1_001_val_1.fq.gz_summits.bed"
N10_37="148-N10_ATAC_H1green_37C_4d__Rep1_S106_L003_R1_001_val__1.fq.gz_summits.bed"
N12_50="148-N12_ATAC_H1green_50C_4d__Rep1_S108_L003_R1_001_val_1.fq.gz_summits.bed"

module load BEDTools/2.30.0-GCC-12.2.0
#bedtools window -w : Base pairs added upstream and downstream of each entry in A when searching for overlaps in B. Default is 1000 bp.
bedtools window -w 1500 -a $peaks/$gDNA_N4 -b $genome_gff > $ATAC/gDNA_N4consensus.bed
bedtools window -w 1500 -a $peaks/$N9_37 -b $genome_gff > $ATAC/37_N9consensus.bed
bedtools window -w 1500 -a $peaks/$N18_50 -b $genome_gff > $ATAC/50_N18consensus.bed
bedtools window -w 1500 -a $peaks/$N13_37 -b $genome_gff > $ATAC/37_N13consensus.bed
bedtools window -w 1500 -a $peaks/$N11_50 -b $genome_gff > $ATAC/50_N11consensus.bed
bedtools window -w 1500 -a $peaks/$N10_37 -b $genome_gff > $ATAC/37_N10consensus.bed

bedtools window -w 1500 -a $peaks/$N12_50 -b $genome_gff > $ATAC/50_N12consensus.bed
bedtools window -w 1000 -a $peaks/$N10_37 -b $genome_gff > $ATAC/37_N10consensus1kb.bed


#module unload BEDTools/2.30.0-GCC-8.3.0

grep "CDS" $ATAC/gDNA_N4consensus.bed > $ATAC/gDNA_N4consensus_CDS.xls
grep "CDS" $ATAC/37_N9consensus.bed > $ATAC/37_N9consensus_CDS.xls
grep "CDS" $ATAC/50_N18consensus.bed > $ATAC/50_N18consensus_CDS.xls
grep "CDS" $ATAC/37_N13consensus.bed > $ATAC/37_N13consensus_CDS.xls
grep "CDS" $ATAC/50_N11consensus.bed > $ATAC/50_N11consensus_CDS.xls
grep "CDS" $ATAC/37_N10consensus.bed > $ATAC/37_N10consensus_CDS.xls
grep "CDS" $ATAC/50_N12consensus.bed > $ATAC/50_N12consensus_CDS.xls
