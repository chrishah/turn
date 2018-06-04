#!/bin/bash
#
#SBATCH -J CELERA
#SBATCH -N 1
#SBATCH --ntasks-per-node 40
#SBATCH -o celera.log.%j.out
#SBATCH -e celera.log.%j.err
#SBATCH -p highmem

###LOAD MODULES
module load gcc/4.9.3

#DEFINE INPUT FILES
prefix=G1234_ec_ind
PE1=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_ind/G1234_ec_ind.1.fastq.gz
PE2=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_ind/G1234_ec_ind.2.fastq.gz
SE=/home/478358/WORKING/G_turnbulli/reads/G1234_ec_ind/G1234_ec_ind.merged.fastq.gz
specfile=Celera_VIPER_highmem.spec
isize="450 100" #insert size estimate 


#############################################################################
##DO SOME WORK
####

frgs=""

echo -e "\n[$(date)]\n### Prepare data ###\n"
#paired end
if [ -s "$PE1" ]
then
	~/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/fastqToCA -libraryname pe -technology illumina-long -innie -mates $PE1,$PE2 -insertsize $isize > pe.frg
	frgs=$frgs'pe.frg '
fi
#single end
if [ -s "$SE" ]
then
	~/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/fastqToCA -libraryname se -technology illumina-long -reads $SE > se.frg
	frgs=$frgs'se.frg'
fi

echo -e "\n[$(date)]\n### ASSEMBLE ###\n"

#run Celera
cmd="/home/478358/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/runCA -p $prefix -d $prefix.assembly -s $specfile $frgs"
echo -e "$cmd"
$cmd

echo -e "\n[$(date)]\n### DONE ###\n"

