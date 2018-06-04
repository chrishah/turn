#!/bin/bash
#
#SBATCH -J extract
#SBATCH -N 1
#SBATCH --ntasks-per-node 5
#SBATCH -o log.%j.out
#SBATCH -e log.%j.err
#SBATCH -p compute

###LOAD MODULES

miraconvert=~/src/MIRA/MIRA_4.0.2/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert
splitscript=/home/478358/WORKING/turn/scripts/split_good_pairs_singletons.pl
prefix=G14-ec-G4-filtered-k31-kgt15-pgt0.9
infile=../G14-ec-G4-filtered-k31-kgt15-pgt0.9-plt1.0.fastq.gz


echo -e "\n[$(date)]\tSTART\n"

echo -e "\n[$(date)]\tExtracting IDs for paired/single end reads\n"
$splitscript $infile #gives list.pe and list.se
cat list.pe | sed -n '1~2p' > list.1
cat list.1 | sed 's/1$/2/' > list.2
rm list.pe

echo -e "\n[$(date)]\tExtracting paired/single end reads from '$infile'\n"
$miraconvert -N list.1 $infile $prefix.1.fastq; rm list.1
$miraconvert -N list.2 $infile $prefix.2.fastq; rm list.2
$miraconvert -N list.se $infile $prefix.se.fastq; rm list.se

#rm $infile

#compress final files
for file in $(ls -1 $prefix.* | grep "fastq$")
do
        gzip -v $file
done

###

echo -e "\n[$(date)]\tDONE!\n"

