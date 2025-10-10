#Li wang advice 10/9/2025
# check md5sum to guarantee nothing wrong with the data

md5sum "$file" > "$output"

# QC check

ml FastQC/0.12.1-Java-11

fastqc "$file" -o “output”
# trim the data if needed.

ml Trimmomatic/0.39-Java-17

trimmomatic PE -threads ${cpus} -phred33 \\

  "${r1}" "${r2}" \\

  "${out_p1}" "${out_u1}" \\

  "${out_p2}" "${out_u2}" \\

  ILLUMINACLIP:"${adapter_file}":2:30:10:8:true \\

  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#merge vcf files, after calling snps for each samples

bcftools merge -h
#check statistic of vcf files

bcftools stats -s - input.vcf > input.stat.txt

# filter data
# you can filter your data based on missing data, Quality, read depth, singleton and so on
# Please always keep your raw raw vcf file!
# Check the gene location: snpeff

ml snpEff/5.2c-GCCcore-12.3.0-Java-11
