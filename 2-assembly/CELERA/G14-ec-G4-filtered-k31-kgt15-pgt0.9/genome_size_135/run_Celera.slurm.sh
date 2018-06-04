#!/bin/bash
#
#SBATCH -J CELERA
#SBATCH -N 1
#SBATCH --ntasks-per-node 40
#SBATCH -o celera.log.%j.out
#SBATCH -e celera.log.%j.err
#SBATCH -p highmem

###LOAD MODULES
module load gcc/5.2.0 
#module load gcc/4.9.3

#DEFINE INPUT FILES
prefix=G14-ec-G4-filtered-k31-kgt15-pgt0.9
IN1=/home/478358/WORKING/turn/3-merging/G14-ec-G4-filtered-k31-kgt15-pgt0.9/G14-ec-G4-filtered-k31-kgt15-pgt0.9_1.nm.fastq.gz
IN2=/home/478358/WORKING/turn/3-merging/G14-ec-G4-filtered-k31-kgt15-pgt0.9/G14-ec-G4-filtered-k31-kgt15-pgt0.9_2.nm.fastq.gz
INME=/home/478358/WORKING/turn/3-merging/G14-ec-G4-filtered-k31-kgt15-pgt0.9/G14-ec-G4-filtered-k31-kgt15-pgt0.9.merged.fastq.gz
specfile=Celera_VIPER_highmem.spec
isize="450 100" #insert size estimate 


#############################################################################
##DO SOME WORK
####

frgs=""

echo -e "\n[$(date)]\n### Prepare data ###\n"
#paired end
if [ -s "$IN1" ]
then
	~/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/fastqToCA -libraryname pe -technology illumina-long -innie -mates $IN1,$IN2 -insertsize $isize > pe.frg
	frgs=$frgs'pe.frg '
fi
#single end
if [ -s "$INME" ]
then
	~/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/fastqToCA -libraryname se -technology illumina-long -reads $INME > se.frg
	frgs=$frgs'se.frg'
fi

echo -e "\n[$(date)]\n### ASSEMBLE ###\n"

#run Celera
cmd="/home/478358/src/CELERA/wgs-8.3rc2/Linux-amd64/bin/runCA -p $prefix -d $prefix.assembly -s $specfile $frgs"
echo -e "$cmd"
$cmd

echo -e "\n[$(date)]\n### DONE ###\n"

