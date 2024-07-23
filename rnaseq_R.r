suppressMessages({
 library("sleuth")
})

#set input and output dirs
datapath <- "/scratch/jms71286/22july2024_results"  # you need to modify this line to match the path made by your BASH script
resultdir <- "/scratch/jms71286/22july2024_results"   # you need to modify this line to match the path made by your BASH script
setwd(resultdir)

#create a sample-to-condition metadata object
sample_id <- dir(file.path(datapath))
kallisto_dirs <- file.path(datapath, sample_id)
sample <- c("SRR1813949", "SRR1813950", "SRR1816873", "SRR3190000", "SRR3190001")
condition <- c("WT", "WT", "dFNR", "dFNR", "dFNR")
samples_to_conditions <- data.frame(sample,condition)
samples_to_conditions <- dplyr::mutate(samples_to_conditions, path = kallisto_dirs)

# check that directories and metadata object are OK
print(kallisto_dirs)
print(samples_to_conditions)

# read data into sleuth_object, make it so you can read in tpms as well
sleuth_object <- sleuth_prep(samples_to_conditions, extra_bootstrap_summary = TRUE, read_bootstrap_tpm=TRUE)

# estimate parameters for the full linear model that includes the conditions as factors
sleuth_object <- sleuth_fit(sleuth_object, ~condition, 'full')

# estimate parameters for the reduced linear model that assumes equal transcript abundances in both conditions
sleuth_object <- sleuth_fit(sleuth_object, ~1, 'reduced')

# perform likelihood ratio test to identify transcripts whose fit is significantly better under full model relative to reduced model
sleuth_object <- sleuth_lrt(sleuth_object, 'reduced', 'full')

# check that sleuth object is OK
models(sleuth_object)

#summarize the sleuth results and visualize results for the 1000 most significant DE transcripts
sleuth_table <- sleuth_results(sleuth_object, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)

pdf(file="SleuthResults.pdf")
for(i in sleuth_significant$target_id[1:1000]) {
  p1 <- plot_bootstrap(sleuth_object, i, units = "tpm", color_by = "condition")
  print(p1)
}
dev.off()

#Quit R
quit(save="no")
