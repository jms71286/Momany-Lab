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

computeMatrix reference-point -S $base/BigWigs/148-N4_ATAC_H1green_gDNA__Rep1_S100_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $base/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $base/BigWigs/148-N9_ATAC_H1green_37C_3d__Rep1_S105_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $base/BigWigs/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw  $base/BigWigs/148-N12_ATAC_H1green_50C_4d__Rep1_S108_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw -R $genome_bed_file -a 2000 -b 1000  \
 -o ${metadir}/euchromatin_matrix.gz \
 --outFileSortedRegions ${metadir}/euchromatin_matrix.bed


plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz -o ${plots}/euchromatin_matrix.png --outFileNameMatrix ${metadir}/euchromatin_matrixmatrix.txt \
--colorMap Greens Greens Greys Greys Greys PuRd PuRd Reds Reds Reds Reds \
--kmeans 4 --clusterUsingSamples 6 7 --sortUsingSamples 7 11 \


plotHeatmap: error: argument --matrixFile/-m: can't open '/lustre2/scratch/jms71286/ATACseq/Heatmap/GZ_files/euchromatin_matrix.gz': [Errno 2] No such file or directory: '/lust$

Error: Unable to open file /lustre2/scratch/jms71286/ATACseq/Heatmap/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw. Exiting.




### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $base/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw -wa  > $ATAC/HeatmapGenes

### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $ATAC/Peaks1/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz_summits.bed -wa > $base/HeatmapGenesN18.txt



#compute matrix  changed 4/14 6:40pm
--outFileSortedRegions $genome_bed_file
--outFileSortedRegions ${metadir}/euchromatin_matrix.bed

#Below is from the website
#####

$ computeMatrix reference-point \ # choose the mode
       --referencePoint TSS \ # alternatives: TES, center
       -b 3000 -a 10000 \ # define the region you are interested in
       -R testFiles/genes.bed \
       -S testFiles/log2ratio_H3K4Me3_chr19.bw  \
       --skipZeros \
       -o matrix1_H3K4me3_l2r_TSS.gz \ # to be used with plotHeatmap and plotProfile
       --outFileSortedRegions regions1_H3K4me3_l2r_genes.bed



$ deepTools2.0/bin/computeMatrix scale-regions \
  -R genes_chr19_firstHalf.bed genes_chr19_secondHalf.bed \ # separate multiple files with spaces
  -S testFiles/log2ratio_*.bw  \ or use the wild card approach
  -b 3000 -a 3000 \
  --regionBodyLength 5000 \
  --skipZeros -o matrix2_multipleBW_l2r_twoGroups_scaled.gz \
  --outFileNameMatrix matrix2_multipleBW_l2r_twoGroups_scaled.tab \
  --outFileSortedRegions regions2_multipleBW_l2r_twoGroups_genes.bed
