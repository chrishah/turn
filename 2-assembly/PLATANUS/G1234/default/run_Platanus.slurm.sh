#!/bin/bash
#
#SBATCH -J PLATANUS
#SBATCH -N 1
#SBATCH --ntasks-per-node 40
#SBATCH -o platanus.log.%j.out
#SBATCH -e platanus.log.%j.err
#SBATCH -p highmem

###LOAD MODULES
module load gcc/4.9.3

#DEFINE INPUT FILES
prefix=G1234_ec_joined
IN1=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234_1.nm.fastq.gz
IN2=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234_2.nm.fastq.gz
INME=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_joined/G1234.merged.fastq.gz
max_mem=700
threads=$SLURM_NTASKS_PER_NODE

#############################################################################
##DO SOME WORK
echo -e "\n[$(date)]\n### Preparing data ###\n"
if [ -s "$IN1" ]
then
	zcat $IN1 > reads.1.fastq
	zcat $IN2 > reads.2.fastq
fi

if [ -s "$INME" ]
then
	zcat $INME > reads.me.fastq
fi

####
echo -e "\n[$(date)]\n### ASSEMBLE ###\n"

platanus assemble -o $prefix -f reads.* -t $threads -m $max_mem 2> assemble.log

echo -e "\n[$(date)]\n### SCAFFOLD ###\n"

platanus scaffold -o $prefix -c $prefix\_contig.fa -b $prefix\_contigBubble.fa -IP1 ./reads.1.fastq ./reads.2.fastq -t $threads 2> scaffold.log

echo -e "\n[$(date)]\n### CLOSE GAPS ###\n"

platanus gap_close -o $prefix -c $prefix\_scaffold.fa -f ./reads.me.fastq -IP1 ./reads.1.fastq ./reads.2.fastq -t $threads 2> gapclose.log

echo -e "\n[$(date)]\n### DONE ###\n"

#cleanup
rm -v reads.*

