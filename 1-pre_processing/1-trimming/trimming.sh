#!/bin/bash

trimmomatic=/home/chrishah/src/TRIMMOMATIC/Trimmomatic-0.38/trimmomatic-0.38.jar
adapterfile=TruSeq3-PE-2.fa
threads=7

#find read pairs
for pair in $(ls -1 ../raw_reads/ | cut -d "_" -f 1 |sort -n | uniq)
do 
	prefix=$(echo "$pair")
	forw=$(ls -1 ../raw_reads/$pair\_* | sort -n | head -n 1)
	reve=$(ls -1 ../raw_reads/$pair\_* | sort -n | tail -n 1)
	echo -e "$prefix\t$forw\t$reve"
	
	mkdir $prefix
	
	#run Trimmomatic
	date
	echo

	java -jar $trimmomatic PE -threads $threads -phred33 $forw $reve $prefix/$prefix\_forward.paired.fastq.gz $prefix/$prefix\_forward.singletons.fastq.gz $prefix/$prefix\_reverse.paired.fastq.gz $prefix/$prefix\_reverse.singletons.fastq.gz ILLUMINACLIP:$adapter:2:30:10 TRAILING:30 LEADING:30 SLIDINGWINDOW:5:20 MINLEN:100 &> $prefix/$prefix\_trim.log

	echo -e "\n$prefix DONE!\n"
	date
done


