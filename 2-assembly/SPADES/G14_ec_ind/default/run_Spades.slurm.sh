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
prefix=G14_ec_ind
IN1=/home/478358/WORKING/G_turnbulli/reads/G14_ec_ind/G14_ec_ind.1.fastq.gz
IN2=/home/478358/WORKING/G_turnbulli/reads/G14_ec_ind/G14_ec_ind.2.fastq.gz
INME=/home/478358/WORKING/G_turnbulli/reads/G14_ec_ind/G14_ec_ind.merged.fastq.gz
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

