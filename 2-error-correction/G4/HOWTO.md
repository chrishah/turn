## Error correction

Concatenate all trimmed reads into a single file:
```
fastq_prefix=/home/chrishah/WORKING/G_turnbulli/1-trimming/G4
prefix=G4

#zcat $fastq_prefix/*fastq.gz | sed "s/ 1:.*/-$prefix\/1/" | sed "s/ 2:.*/-$prefix\/2/" | gzip > all_reads.fastq.gz
zcat $fastq_prefix/*fastq.gz | sed "s/ 1:.*/-$prefix\/1/" | sed "s/ 2:.*/-$prefix\/2/" > all_reads.fastq
```


Call up the BLESS container:
```
prefix=G4
sudo docker run --name $prefix --rm -i -t --net=host -v $(pwd):/home/working chrishah/bless /bin/bash
```

In the container, run:
```
./bless_iterate_over_ks.sh all_reads.fastq G4 21 > iterate.log
```

This will run BLESS across a number k-mer lengths. Starting with k=21 (as specified) the k-mer length will be increased (in steps of 2 up to k = intial_k + 20) until the optimal correction has been obtained. Criteria for 'optimal correction' from BLESS [wiki](https://sourceforge.net/p/bless-ec/wiki/Home/): 1) Ns / 4 ^ k < 0.0001; 2) k with the maximum number of bases corrected. The fastq input file is 'all_reads.fastq.gz'. Results will have the prefix 'G2'.

Exit the container:
```
exit
```

Cleanup:
```
rm all_reads.fastq
```

Find and extract good pairs and orphans:
```
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert
prefix=G4
infile=G4-k21.corrected.fastq

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

rm $infile

#compress final files
for file in $(ls -1 $prefix.corrected*)
do
        gzip $file
done
```
