#!/bin/bash
#
#SBATCH -J SPADES
#SBATCH -N 1
#SBATCH --ntasks-per-node 40
#SBATCH -o spades.log.%j.out
#SBATCH -e spades.log.%j.err
#SBATCH -p highmem

###LOAD MODULES
module load gcc/4.9.3

###
spades=/home/478358/src/SPADES/SPAdes-3.9.0-Linux/bin/spades.py

#DEFINE INPUT FILES
prefix=G1234_ec_joined
IN1=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234_1.nm.fastq.gz
IN2=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234_2.nm.fastq.gz
INME=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234.merged.fastq.gz
max_mem=800
threads=$SLURM_NTASKS_PER_NODE

#############################################################################
##DO SOME WORK

echo -e "\n[$(date)]\n### ASSEMBLY ###\n"

$spades \
--only-assembler \
--careful \
--cov-cutoff auto \
-t $threads \
-m $max_mem \
-o ./assembly \
--pe1-1 $IN1 \
--pe1-2 $IN2 \
--s1 $INME 


echo -e "\n[$(date)]\n### DONE ###\n"

