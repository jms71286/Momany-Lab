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

base=/lustre2/scratch/jms71286/ATACseq/Heatmap
plots=${base}/Plots
metadir=${base}/GZ_files
genome_bed_file="/scratch/jms71286/ATACseq/Peaks1/148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz_summits.bed"


module load deepTools/3.5.2-foss-2022a

computeMatrix reference-point --referencePoint TSS  -R $genome_bed_file -b 1500 -a 1000   \
    -S $ATAC/BigWigs/148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $ATAC/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $ATAC/BigWigs/148-N9_ATAC_H1green_37C_3d__Rep1_S105_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $ATAC/BigWigs/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $ATAC/BigWigs/148-N12_ATAC_H1green_50C_4d__Rep1_S108_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw
    --samplesLabel "H1green_gDNA" "N13_37C" "N9_37C" "N18_50C" "N12_50C"  \
    -o ${metadir}/euchromatin_matrix.gz \
    --outFileSortedRegions ${metadir}/euchromatin_matrix.bed

    plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz -o ${plots}/euchromatin_matrix.png --outFileNameMatrix  ${metadir}/euchromatin_matrixmatrix.txt \
      --colorMap Greens Greens Greys Greys Greys PuRd PuRd Reds Reds Reds Reds \
      --kmeans 4 --clusterUsingSamples 6 7 --sortUsingSamples 7 11 \
      --linesAtTickMarks --heatmapHeight 18 --heatmapWidth 3 --dpi 600 --missingDataAsZeros


### get genes overlapping with Peaks
ml BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $ATAC/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw -wa  > HeatmapGenes
