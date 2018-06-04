#!/bin/bash
#
#SBATCH -J kmc
#SBATCH -N 1
#SBATCH --ntasks-per-node 28
#SBATCH -o log.kmer-filter.%j.out
#SBATCH -e log.kmer-filter.%j.err
#SBATCH -p compute

# Execute the job code
###LOAD MODULES

#############################################################################
##DO SOME WORK

prefix=G1-ec
fastq=
fastq_dir=/home/478358/WORKING/G_turnbulli/reads/G1/ec/*
fofn=fofn.txt
k=21
maxcount=10000
db_prefix=$prefix-k$k
min_kmer_cov=20
max_kmer_cov=60
min_perc_kmers=0.8
outfastq=filtered.fastq
threads=$SLURM_NTASKS_PER_NODE



kmc_tools filter $db_prefix -ci$min_kmer_cov -cx$max_kmer_cov @$fofn -ci$min_perc_kmers $outfastq

gzip $outfastq
