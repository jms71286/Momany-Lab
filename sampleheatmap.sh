#!/bin/bash
#SBATCH --job-name=adheatmapping
#SBATCH --partition=batch
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jms71286@uga.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=50gb
#SBATCH --time=1:00:00
#SBATCH --output=../logs/heatmap.%j.out
#SBATCH --error=../logs/heatmap.%j.err

base=/lustre2/scratch/jms71286/ChIPseq/PeritheciaChIPAnalysis/Heatmap_For_Paper
plots=${base}/Plots
metadir=${base}/GZ_Files
peri=${base}/Perithecia_Files
Run141=/lustre2/scratch/ad45368/ChIPseq/PeritheciaChIPAnalysis/OutputRNA/bigWig

module load deepTools/3.5.2-foss-2022a
genome_bed_file=?


mkdir $plots
mkdir $metadir


computeMatrix reference-point --referencePoint TSS  -R $genome_bed_file -b 500 -a 300   \
    -S ${base}/SRR7690280.bin_25.smooth_75Bulk.bw ${peri}/Peri_H3K27me3.bw ${base}/Mycelia_ATAC_merge.bw  ${base}/140-N11_ATAC_6dpf_WT__.bin_25.smooth_75Bulk.bw ${peri}/140-N10_ATAC_6dpf_WT__.bin_25.smooth_75Bulk.bw  ${base}/SRR12229307.bin_25.smooth_75Bulk.bw ${peri}/Peri_H3K4me2.bw ${base}/Mycelia_RNA_control_log.bw ${Run141}/141-113_cDNA_WTmata_PP__Rep2_log.bw ${Run141}/141-109_cDNA_set7mata_FP__Rep2_log.bw ${peri}/Peri_RNA.bw  \
    --samplesLabel "M_K27me3" "P_K27me3" "M_ATAC" "M_ATAC141" "P_ATAC" "M_K4" "P_K4" "M_RNA" "PP_RNA" "FP_RNA" "P_RNA" \
    -o ${metadir}/euchromatin_matrix.gz \
    --outFileSortedRegions ${metadir}/euchromatin_matrix.bed

    plotHeatmap --matrixFile ${metadir}/euchromatin_matrix.gz -o ${plots}/euchromatin_matrix.png --outFileNameMatrix ${metadir}/euchromatin_matrixmatrix.txt \
      --colorMap Greens Greens Greys Greys Greys PuRd PuRd Reds Reds Reds Reds \
      --kmeans 4 --clusterUsingSamples 6 7 --sortUsingSamples 7 11 \
      --linesAtTickMarks --heatmapHeight 18 --heatmapWidth 3 --dpi 600 --missingDataAsZeros


### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b <bed file from peak calling> -wa  > filename


#JS edit 4/14
### get genes overlapping with Peaks
module load BEDTools/2.30.0-GCC-12.2.0
bedtools intersect -a $genome_bed_file -b $ATAC/Peaks1/148-N18_ATAC_H1green_50C_3d__Rep2_S114_L003_R1_001_val_1.fq.gz_summits.bed -wa > $base/HeatmapGenesN18.txt
