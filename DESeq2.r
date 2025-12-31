if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("DESeq2")

#The downloaded binary packages are in /var/folders/kk/1dwj12sn2l7b364gj7yq1qkm0000gn/T//RtmpaFkPFF/downloaded_packages

#load libraries
library(DESeq2)
library(pheatmap)
library(dplyr)
library(RColorBrewer)
library(ggplot2)
library(ggrepel)

#set working directory
setwd("/Users/justinastanislaw/DESeq2")

#load the count data
> count_data_new <- read.csv('/Users/justinastanislaw/Desktop/counts_matrix.csv',header = TRUE, row.names=1)
> colnames(count_data_new)
> head(count_data_new)

#make sure no integers first
> count_data_new <- as.matrix(count_data_new)
> mode(count_data_new) <- "integer"

#load sample data
> sample_info <- read.csv('/Users/justinastanislaw/Desktop/sample_info_condition.csv',header = TRUE,row.names=1)
> colnames(sample_info)
> head(sample_info)

#check that the column names match exactly. If FALSE, then fix
> all(colnames(count_data_new) == rownames(sample_info))

#set factors
> sample_info$condition <- factor(sample_info$condition)
> dds <- DESeqDataSetFromMatrix(countData = count_data_new,colData = sample_info, design = ~ condition)

#pre-filter (remove very low-count genes) and run DESeq2 !
keep <- rowSums(counts(dds)) >= 5
dds  <- dds[keep,]
> dds2 <- DESeq(dds)

# Extract results
deseq_result <- results(dds)
deseq_result

# Extract results for a specific contrast ?? dont know if worked
# treat1 vs control
res_treat1_vs_37hyphctrl <- results(dds, contrast = c("condition",
                                                "Treat1",
                                                "Control"))

# For treat2 vs control
res_treat2_vs_37hyphctrl <- results(dds, contrast = c("condition",
                                                "Treat2",
                                                "Control"))

#make deseq object into R object
deseq_result <- as.data.frame(deseq_result)
class(deseq_result)

#Order and inspect
deseq_result_ordered <- deseq_result[order(deseq_result$pvalue), ]
head(deseq_result)

#filter based upon adjusted pval (padj) <0.05
filtered <- deseq_result %>% filter(deseq_result$padj < 0.05)

#filter based upon log2FC >2
filtered <- filtered %>% filter(abs(filtered$log2FoldChange) > 2 )

dim(deseq_result)
dim(filtered)

#save results!
write.csv(deseq_result,'de_result.all.csv')
write.csv(filtered,'de_result.filtered.csv')

#save normalized counts
normalized_counts <- counts(dds,normalized=TRUE)
head(normalized_counts)
write.csv(normalized_counts,'normalized_counts.all.csv')






#VISUALIZATION
#Dispersion
plotDispEsts(dds)

# install.packages("ggplot2")
# install.packages("ggfortify")
# install.packages("factoextra")

library(ggplot2)
library(ggfortify)
library(factoextra)

#PCA - principal component analysis - dimensional reduction technique; used to explain variance
vsd <- vst(dds,blind=FALSE)
plotPCA(vsd,intgroup=c("condition"))
#need to fix the y and y axis ticks

#HEATMAPS
#plot heatmap sample-sample distance matrix with clustering based upon normalized read counts
#generate distance matrix
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <-as.matrix(sampleDists)
colnames(sampleDistMatrix)

#set color scheme
colors <- colorRampPalette(rev(brewer.pal(9,"Blues")))(255)

#generate heatmap
pheatmap(sampleDistMatrix, clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists, col=colors)

#plot heatmap of log transformed normalized counts... we will use top 50 genes
top_hits <- deseq_result[order(deseq_result$padj), ][1:50,]
top_hits <- row.names(top_hits)
top_hits

rld <- rlog(dds,blind=FALSE)
pheatmap(assay(rld)[top_hits,], cluster_rows=FALSE,show_rownames=TRUE,cluster_cols=FALSE)


#heatmap of z-scores
cal_z_score <- function(x) {(x-mean(x)) / sd(x)}
zscore_all <- t(apply(normalized_counts, 1, cal_z_score))
zscore_subset <- zscore_all[top_hits,]
pheatmap(zscore_subset)



#MA plot
BiocManager::install("apeglm")
library(BiocManager)

#plot MA plot dirty
plotMA(dds,ylim=c(-2,2))

#remove noise MA plot
resLFC <- lfcShrink(dds,coef="condition_Treat1_vs_Control",type="apeglm")
plotMA(resLFC,ylim=c(-2,2))


#Volcano plot
#change resLFC to dataframe
resLFC <- as.data.frame(resLFC)

#label the genes
resLFC$diffexpressed <- "NO"
resLFC$diffexpressed[resLFC$log2FoldChange>1 & resLFC$padj<0.05] <- "UP"
resLFC$diffexpressed[resLFC$log2FoldChange>1 & resLFC$padj<0.05] <- "DOWN"
resLFC$delabel<-NA

ggplot(data=resLFC,aes(x=log2FoldChange,y=-log10(pvalue),col=diffexpressed,label=delabel))+
  geom_point()+
  theme_minimal()+
  geom_text_repel()+
  scale_color_manual(values=c('blue','black','red'))+
  theme(text=element_text(size=20))
