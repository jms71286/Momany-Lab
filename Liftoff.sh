



#annotate final polished genome with Liftoff

curl -s https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/945/GCF_000006945.2_ASM694v2/GCF_000006945.2_ASM694v2_genomic.gff.gz \

| gunzip -c > $workdir/LT2_features.gff



module load liftoff/1.6.3



mkdir $outdir/liftoff

liftoff -p 2 -copies -g $workdir/LT2_features.gff -o $outdir/liftoff/JE8034_features.gff -dir $workdir/liftoff_intermediate_files $outdir/circlator/JE8034_circlator.fasta $workdir/LT2.fna
