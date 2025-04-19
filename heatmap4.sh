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
genome_bed_file="/scratch/jms71286/ATACseq/Genome/Afum_A1163_edit6.bed"

### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $base/BigWigs/148-N13_ATAC_H1green_37C_3d__Rep2_S109_L003_R1_001_val_1.fq.gz.ATAC_bin_3.smooth_6_Bulk.bw -wa  > $ATAC/HeatmapGenes

### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $ATAC/Peaks1/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz_summits.bed -wa > $base/HeatmapGenesN18.bed
#open bed in excel
