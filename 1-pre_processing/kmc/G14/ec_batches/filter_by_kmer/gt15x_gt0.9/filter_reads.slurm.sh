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
prefix=G14-ec-G4
fastq=
fastq_dir=/home/478358/WORKING/G_turnbulli/reads/G1/ec-G4/
fastq_dir2=/home/478358/WORKING/G_turnbulli/reads/G4/ec/
fofn=fofn.txt
k=31
maxcount=10000
db_prefix=/home/478358/WORKING/G_turnbulli/kmc/G14/ec_batches/$prefix-k$k
min_kmer_cov=15
max_kmer_cov=
min_perc_kmers=0.9
max_perc_kmers=1.0
outfastq=$prefix-filtered-k$k
threads=$SLURM_NTASKS_PER_NODE

#############################################################################
## Do some work:
if [ "$fastq_dir" ]
then
        ls -1 $fastq_dir/* | grep "fastq"
        ls -1 $fastq_dir2/* | grep "fastq"
elif [ "$fastq" ]
then
	ls -1 $fastq
fi > fofn.txt

cmd="kmc_tools filter $db_prefix "

if [ "$min_kmer_cov" ]
then
	cmd="$cmd -ci$min_kmer_cov "
	outfastq="$outfastq-kgt$min_kmer_cov"
fi

if [ "$max_kmer_cov" ]
then
	cmd="$cmd -cx$max_kmer_cov "
	outfastq="$outfastq-klt$max_kmer_cov"
fi

if [ "$fastq" ]
then
	cmd="$cmd $fastq "
elif [ "$fofn" ]
then
	cmd="$cmd @$fofn "	
fi

if [ "$min_perc_kmers" ]
then
	cmd="$cmd -ci$min_perc_kmers "
	outfastq="$outfastq-pgt$min_perc_kmers"
fi

if [ "$max_perc_kmers" ]
then
	cmd="$cmd -cx$max_perc_kmers "
	outfastq="$outfastq-plt$max_perc_kmers"
fi

cmd="$cmd $outfastq.fastq"

echo -e "Filtering reads: \n$(cat $fofn)\n"
echo -e "$cmd\n"
$cmd

gzip $outfastq.fastq
