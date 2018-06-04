#!/bin/bash
#
#SBATCH -J merge
#SBATCH -N 1
#SBATCH --ntasks-per-node 4
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES
module load perl/5.24.0


usearch=~/src/USEARCH/usearch10.0.240_i86linux32
usearch_merge=../../scripts/usearch_mergepairs.sh

prefix=G14-ec-G4-filtered-k31-kgt15-pgt0.9
forw=/home/478358/WORKING/turn/3-merging/../../G_turnbulli/kmc/G14/ec_batches/filter_by_kmer/gt15x_gt0.9/extract_pairs/G14-ec-G4-filtered-k31-kgt15-pgt0.9.1.fastq.gz
reve=/home/478358/WORKING/turn/3-merging/../../G_turnbulli/kmc/G14/ec_batches/filter_by_kmer/gt15x_gt0.9/extract_pairs/G14-ec-G4-filtered-k31-kgt15-pgt0.9.2.fastq.gz


cmd="$usearch_merge $forw $reve $prefix $usearch"

echo -e "\n[$(date)]\t$cmd\n"
$cmd

