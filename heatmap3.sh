#!/bin/bash
#SBATCH --job-name=heatmap
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

base=/scratch/jms71286/ATACseq/Heatmap
plots=${base}/Plots
metadir=${base}/GZ_files
genome_bed_file="/scratch/jms71286/ATACseq/Peaks1/148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz_summits.bed"

module load deepTools/3.5.2-foss-2022a

computeMatrix reference-point -R $genome_bed_file -a 1000 -b 2000  \
-S $ATAC/BigWigs/148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw $ATAC/BigWigs/148-N9_ATAC_H1green_37C_3d__Rep1_S105_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw $ATAC/BigWigs/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  \
-o ${metadir}/euchromatin_matrix.gz \ # to be used with plotHeatmap and plotProfile
--skipZeros \
--outFileSortedRegions $genome_bed_file
--outFileSortedRegions ${metadir}/euchromatin_matrix.bed

plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz -o ${plots}/euchromatin_matrix.png
plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz --outFileNameMatrix ${metadir}/euchromatin_matrixmatrix.txt \

### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $ATAC/Peaks1/148-N9_ATAC_H1green_37C_3d__Rep1_S105_L003_R1_001_val_1.fq.gz_summits.bed -wa > $base/HeatmapGenesN9.txt
bedtools intersect -a $genome_bed_file -b $ATAC/Peaks1/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz_summits.bed -wa > $base/HeatmapGenesN18.txt
