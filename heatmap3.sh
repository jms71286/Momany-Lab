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
  -o ${metadir}/euchromatin_matrix.gz \
 --outFileSortedRegions ${metadir}/euchromatin_matrix.bed

 plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz -o ${plots}/euchromatin_matrix.png --outFileNameMatrix ${metadir}/euchromatin_matrixmatrix.tab \
#  --samplesLabel "M_K27me3" "P_K27me3" "M_ATAC" "M_ATAC141" "P_ATAC" "M_K4" "P_K4" "M_RNA" "PP_RNA" "FP_RNA" "P_RNA" \
