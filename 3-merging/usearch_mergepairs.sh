#!/bin/bash
usearch=/home/chrishah/src/USEARCH/usearch10.0.240_i86linux32
prefix=$3

batchsize=4000000

total=$(zcat $1 | grep "^+$" |wc -l)

batches=$(echo -e "$total\t$batchsize" | perl -ne 'chomp; @a=split("\t"); $ret=sprintf("%0.f",(($a[0]/$a[1])+0.5)); print "$ret\n"')

echo -e "\n[$(date)]\tDetected $total read pairs - Merging in $batches batches of $batchsize reads\n"

for a in $(seq 1 $batches)
do
	echo -en "[$(date)]\t\tprocessing Batch\t$a ... "

	paste <(zcat $1) <(zcat $2) <(echo "$a") <(echo "$batchsize") | perl -ne 'chomp; @a=split("\t"); if ($. == 1){$batch=pop(@a); $factor=pop(@a);}; if ($. >= ($factor * ($batch*4) - ($batch*4) + 1)){ print "$a[0]\n"; print STDERR "$a[1]\n"}; if ($. >= ($factor * ($batch*4))){exit;}' 1> sub_$a\_1.fastq 2> sub_$a\_2.fastq

	echo -e "\n#####\nBatch $a\n#####\n" > merge_$a.log

	$usearch -fastq_mergepairs sub_$a\_1.fastq -reverse sub_$a\_2.fastq -fastq_trimstagger -fastqout_notmerged_fwd sub_$a\_1.nm.fastq -fastqout_notmerged_rev sub_$a\_2.nm.fastq -fastqout sub_$a.merged.fastq &>> merge_$a.log

#	rm sub_$a\_?.fastq
	echo -e "Done!"
done

echo -e "\n[$(date)]\t\tConcatenating, compressing and removing temporary files"
cat *merged.fastq | perl -ne 'if ((($.-1)%4) == 0){chomp; print substr($_,0,-2)."\n"}else{print $_}' | gzip > $prefix.merged.fastq.gz
rm *.merged.fastq

for f in $(ls -1 *_1.nm.fastq | grep "^sub"); do for=$f; cat $for; done | gzip > $prefix\_1.nm.fastq.gz
#cat *1.nm.fastq | gzip > $prefix\_1.nm.fastq.gz
#rm *1.nm.fastq

for f in $(ls -1 *_1.nm.fastq | grep "^sub"); do for=$f; rev=$(echo -e "$f" | sed 's/_1.nm.fastq/_2.nm.fastq/'); cat $rev; done | gzip > $prefix\_2.nm.fastq.gz
#cat *2.nm.fastq | gzip > $prefix\_2.nm.fastq.gz
#rm *2.nm.fastq

cat merge_* > merging.log
rm merge_*

echo -e "\n[$(date)]\tAll Done!\n"
