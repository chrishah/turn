
Find and extract good pairs and orphans:
```
miraconvert=~/src/MIRA/MIRA_4.0.2/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert
splitscript=/home/478358/WORKING/turn/scripts/split_good_pairs_singletons.pl
prefix=G14-ec-G4-filtered-k31-kgt15-pgt0.9
infile=G14-ec-G4-filtered-k31-kgt15-pgt0.9-plt1.0.fastq.gz

$splitscript $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.se.fastq; rm list.se

rm $infile

#compress final files
for file in $(ls -1 $prefix.* | grep "fastq$")
do
        gzip -v $file
done
```
