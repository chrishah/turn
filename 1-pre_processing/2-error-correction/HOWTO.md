# correct errors with bless

```
mkdir G1
mkdir G2
mkdir G3
mkdir G4
```


#####################G1

fastq_prefix=/home/chrishah/WORKING/G_turnbulli/1-trimming/G1
prefix=G1

mkdir $prefix
cd $prefix

zcat $fastq_prefix/*fastq.gz | sed 's/ 1:.*/\/1/' | sed 's/ 2:.*/\/2/' | gzip > all_reads.fastq.gz

k=21
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -gzip -prefix $prefix-k$k > bless-k$k.log

#How to select the ideal kmer size k:
#from BLESS homepage:
#Number of unique kmers/4^k should be < 0.0001
#Number of unique solid 21-mers: 69002812 (from BLESS log)
#-> 69002812/4^21 = 0.000015689
# OK! #

#check automatically!!
echo $(cat bless-k$k.log | grep "k-mer length" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') $(cat bless-k$k.log | grep "Number of unique solid k-mers" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') | perl -ne 'chomp; @a=split(" "); $res=($a[1]/(4**$a[0])); if ($res < 0.0001){print "$res -> OK!\n"}else{print "$res -> NOT OK!\n"}'


cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 10472507


#best kmer size criterion 2 is: increase k until the number of corrected bases becomes the maximum

#RERUN with k=23
k=23
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -gzip -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 8210966

#-> k=21 is the winner

#ok cleanup reads
rm all_reads.fastq.gz
rm G1-k23.* 

#find good pairs and orphans
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert

prefix=G1
infile=G1-k23.corrected.fastq.gz

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

rm $infile

for file in $(ls -1 $prefix.corrected*)
do
	gzip $file
done

cd ..


#####################G2

fastq_prefix=/home/chrishah/WORKING/G_turnbulli/1-trimming/G2
prefix=G2

mkdir $prefix
cd $prefix

zcat $fastq_prefix/*fastq.gz | sed 's/ 1:.*/\/1/' | sed 's/ 2:.*/\/2/' | gzip > all_reads.fastq.gz

k=21
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log

#How to select the ideal kmer size k:
#from BLESS homepage:
#Number of unique kmers/4^k should be < 0.0001
#Number of unique solid 21-mers: 713435631 (from BLESS log)
#-> 713435631/4^21 = 0.000162216
# NOT OK! #

#check automatically!!
echo $(cat bless-k$k.log | grep "k-mer length" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') $(cat bless-k$k.log | grep "Number of unique solid k-mers" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') | perl -ne 'chomp; @a=split(" "); $res=($a[1]/(4**$a[0])); if ($res < 0.0001){print "$res -> OK!\n"}else{print "$res -> NOT OK!\n"}'


#RERUN with k=23

k=23
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log

#Number of unique kmers/4^k should be < 0.0001
#Number of unique solid 23-mers: 725692624 (from BLESS log)
#-> 725692624/4^23 = 0.000010313
# OK! #

#check automatically!!
echo $(cat bless-k$k.log | grep "k-mer length" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') $(cat bless-k$k.log | grep "Number of unique solid k-mers" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') | perl -ne 'chomp; @a=split(" "); $res=($a[1]/(4**$a[0])); if ($res < 0.0001){print "$res -> OK!\n"}else{print "$res -> NOT OK!\n"}'

cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 7660311

#best kmer size criterion 2 is: increase k until the number of corrected bases becomes the maximum

#RERUN with k=25
k=25
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 7729870

#-> k=25 corrected more errors than k=23
rm G2-k23.*

#RERUN with k=27
k=27
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 7796349

#-> k=27 corrected more errors than k=25
rm G2-k25.*

#RERUN with k=29
k=29
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 7874080

#-> k=29 corrected more errors than k=27
rm G2-k27.*

#RERUN with k=31
k=31
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 7934097

#-> k=31 corrected more errors than k=29
rm G2-k29.*

#RERUN with k=33
k=33
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#




#ok cleanup reads
rm all_reads.fastq.gz
rm 

#find good pairs and orphans
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert

prefix=G2
infile=

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

rm $infile

for file in $(ls -1 $prefix.corrected*)
do
	gzip $file
done

cd ..




#####################G3

fastq_prefix=/home/chrishah/WORKING/G_turnbulli/1-trimming/G3
prefix=G3

mkdir $prefix
cd $prefix

zcat $fastq_prefix/*fastq.gz | sed 's/ 1:.*/\/1/' | sed 's/ 2:.*/\/2/' | gzip > all_reads.fastq.gz

k=21
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log

#How to select the ideal kmer size k:
#from BLESS homepage:
#Number of unique kmers/4^k should be < 0.0001
#Number of unique solid 21-mers: 624730248 (from BLESS log)
#-> 624730248/4^21 = 0.000142047
# NOT OK! #

#check automatically!!
echo $(cat bless-k$k.log | grep "k-mer length" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') $(cat bless-k$k.log | grep "Number of unique solid k-mers" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') | perl -ne 'chomp; @a=split(" "); $res=($a[1]/(4**$a[0])); if ($res < 0.0001){print "$res -> OK!\n"}else{print "$res -> NOT OK!\n"}'

##RERUN WITH kmer 23

k=23
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log

#Number of unique solid 23-mers: 630475606 (from BLESS log)
#-> 630475606/4^23 = 0.00000896
# OK! #

cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 4559623

#best kmer size criterion 2 is: increase k until the number of corrected bases becomes the maximum

#RERUN with k=25
k=25
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 13163334

#-> k25 corrected more errors
rm G3-k23.*

#RERUN with k=27
k=27
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 11988220

#-> k25 is the winner


#ok cleanup reads
rm all_reads.fastq.gz
rm G3-k27.*

#find good pairs and orphans
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert

prefix=G3
infile=G3-k25.corrected.fastq

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

rm $infile

for file in $(ls -1 $prefix.corrected*)
do
	gzip $file
done

cd ..



#####################G4

fastq_prefix=/home/chrishah/WORKING/G_turnbulli/1-trimming/G4
prefix=G4

mkdir $prefix
cd $prefix

zcat $fastq_prefix/*fastq.gz | sed 's/ 1:.*/\/1/' | sed 's/ 2:.*/\/2/' | gzip > all_reads.fastq.gz

k=21
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log

#How to select the ideal kmer size k:
#from BLESS homepage:
#Number of unique kmers/4^k should be < 0.0001
#Number of unique solid 21-mers: 71114916 (from BLESS log)
#-> 71114916/4^21 = 0.00001617
# OK! #

#check automatically!!
echo $(cat bless-k$k.log | grep "k-mer length" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') $(cat bless-k$k.log | grep "Number of unique solid k-mers" | perl -ne 'chomp; @a=split(" "); print "$a[-1]\n"') | perl -ne 'chomp; @a=split(" "); $res=($a[1]/(4**$a[0])); if ($res < 0.0001){print "$res -> OK!\n"}else{print "$res -> NOT OK!\n"}'

cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 12801689

#best kmer size criterion 2 is: increase k until the number of corrected bases becomes the maximum

#RERUN with k=23
k=23
sudo docker run --name $prefix --rm -i -t -v $(pwd):/home/working chrishah/bless -read all_reads.fastq.gz -kmerlength $k -notrim -prefix $prefix-k$k > bless-k$k.log
cat bless-k$k.log | grep "Number of corrected errors"
#Number of corrected errors: 8787584

#-> k21 is the winner

#ok cleanup reads
rm all_reads.fastq.gz
rm G4-k23.* 

#find good pairs and orphans
miraconvert=/home/chrishah/src/MIRA/mira_4.0.2_linux-gnu_x86_64_static/bin/miraconvert

prefix=G4
infile=G4-k21.corrected.fastq.gz

~/Dropbox/Github/local/scripts/mine/Perl/split_good_pairs_singletons.pl $infile #gives list.pe and list.se
cat list.pe | perl -ne 'if ($_ =~ /1$/){print "$_"}else{print STDERR "$_"}' > list.1 2> list.2 ; rm list.pe #split paired read ids into separate files
$miraconvert -n list.1 $infile $prefix.corrected.1.fastq; rm list.1
$miraconvert -n list.2 $infile $prefix.corrected.2.fastq; rm list.2
$miraconvert -n list.se $infile $prefix.corrected.se.fastq; rm list.se

rm $infile

for file in $(ls -1 $prefix.corrected*)
do
	gzip $file
done

cd ..



