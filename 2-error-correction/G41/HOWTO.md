## Error correction

Correct G1 in batches of <5M reads together with full G4.

Call up the BLESS container:
```
prefix=G41
sudo docker run --name $prefix --rm -i -t --net=host -v $(pwd)/../:/home/working chrishah/bless /bin/bash
```

In the container
```
cd G41/

ref_read=../G4/G4.corrected.*
cor_read=../G1/G1.corrected.*
batchsize=10000000

paste <(zcat $cor_read) <(echo "$batchsize") | perl -ne 'chomp; @a=split(" "); if ($. == 1){$batch=1; $count=0; open FH, ">", "batch-".sprintf("%08d", $batch).".fastq"; $bsize=pop(@a);} $_ = $a[0]."\n"; if ((($.-1) % 4) == 0){$count++; if (($count % ($bsize)) == 0){print "Done writing batch $batch\n"; $batch++; close(FH); open FH, ">", "batch-".sprintf("%08d", $batch).".fastq"; }} print FH "$_"'


for batch in $(ls -1 *.fastq | grep "^batch" | grep -v "corrected")
do
	b=$(echo $batch | sed 's/\.fastq$//')
	echo -e "\n$(date)\tProcessing $b ($batch)\n"
	cat <(cat $batch) <(zcat $ref_read) > all_reads-$batch
	rm $batch

	../bless_iterate_over_ks.sh all_reads-$batch $b 21 > iterate-$b.log
	rm all_reads-$batch
	for blesslog in $(ls -1 bless-k*)
	do
		mv $blesslog $b-$blesslog
	done
done

```

Exit the container.
```
exit
```

Fin and extct G1 sequences:
```
prefix=G14
extract=G1

for f in $(ls -1 *.fastq | grep "^batch-")
do
        cat $f | grep "$extract/[1-2]$" -A 3
done > $prefix.corrected.fastq


for f in $(ls -1 *.fastq | grep -v "^$prefix.corrected.fastq")
do
        rm $f
done
```

Extract good pairs and orphans:
```
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert
prefix=G14
infile=G14.corrected.fastq

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

#rm $infile

#compress final files
for file in $(ls -1 $prefix.corrected*)
do
        gzip $file
done
```
