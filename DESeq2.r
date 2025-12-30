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
