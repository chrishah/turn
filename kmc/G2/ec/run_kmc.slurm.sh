#!/bin/bash
#
#SBATCH -J kmc
#SBATCH -N 1
#SBATCH --ntasks-per-node 28
#SBATCH -o log.kmc.%j.out
#SBATCH -e log.kmc.%j.err
#SBATCH -p compute

# Execute the job code
###LOAD MODULES

#############################################################################
##DO SOME WORK

prefix=G2-ec
fastq=
fastq_dir=/home/478358/WORKING/G_turnbulli/reads/G2/ec/
fofn=fofn.txt
k=21
maxcount=10000
threads=$SLURM_NTASKS_PER_NODE

#############################################################################
## Do some work:
if [ "$fastq_dir" ]
then
        ls -1 $fastq_dir/* | grep "fastq" > fofn.txt
fi


read_stats=$(for f in $(cat fofn.txt)
do
        zcat $f
done | sed -n '2~4p' | perl -ne 'chomp; $cum=$cum+length($_); if (eof()){print "$cum\t".sprintf("%.2f", $cum/$.)."\n"}')

cum_length=$(echo -e "$read_stats" | cut -f 1)
avg_length=$(echo -e "$read_stats" | cut -f 2)

echo -e "$prefix\ncummulative length: $cum_length\naverage read length: $avg_length\n"

date

echo

echo -e "counting kmers\n"
mkdir kmer_k$k\_lib
if [ -s "$fofn" ]
then
        kmc -k$k -cs$maxcount -t$threads -v @$fofn $prefix-k$k kmer_k$k\_lib/
elif [ -s "$fastq" ]
then
        kmc -k$k -cs$maxcount -t$threads -f $fastq $prefix-k$k kmer_k$k\_lib/
fi

date

echo -e "creating histogram"
kmc_tools histogram $prefix-k$k -ci1 -cx$maxcount $prefix-k$k.hist.txt

#echo -e "\ndumping kmers\n"
#kmc_tools dump $prefix-k$k $prefix\_kmer-k$k-dump.txt
#date

#echo -e "\ncreating kmer counts txt file\n"
#cat $prefix\_kmer-k$k-dump.txt |cut -f 2 | sort -n | uniq -c | perl -ne 'chomp; @a=split(" "); print "$a[-2]\t$a[-1]\n"' > $prefix\_kmer-k$k-hist.txt

#paste $prefix\_kmer-k$k-dump.txt <(echo -e "$k")| sed 's/[GC]//g' | perl -ne 'chomp; @a=split("\t"); if ($a[2]){$kmer=$a[2]}; $GC=sprintf("%.6f", (1-(length($a[0])/$kmer))); print "$a[1]\t$GC\n" ' | sort -n > $prefix\_kmer-k$k-cov-vs-GC.txt

#cleanup
rm -rf kmer_k$k\_lib/

echo -e "\nDONE!"
date

module load R/3.4.1

echo -e "setwd(\"$(pwd)\")

data = read.table(\"$prefix-k$k.hist.txt\", sep=\"\\\t\", col.names=c(\"kmer_cov\",\"count\"))

sample=\"$prefix\"
kmer_size=$k
cum_read_length=$cum_length
avg_read_length=$avg_length

minsearch=5
maxsearch=200

frequency=data\$count/sum(data\$count)

for (i in minsearch:maxsearch+1){
  if ( max(data\$count[i:maxsearch]) != data\$count[i]){
    if ( data\$count[i-1] > data\$count[i] & data\$count[i] < data\$count[i+1] & max(data\$count[i:maxsearch])/data\$count[i] >= 2 ){
      if ( (which(data\$count == max(data\$count[i:maxsearch])) - i) >= 5 ){
        break
      }
    }
  }
}

#if ( which(data\$count == max(data\$count[minsearch:maxsearch])) > minsearch ){
if (i <= maxsearch){
  #find peak
#  valley <- i-1
#  index <- which(data\$count == max(data\$count[valley:maxsearch]))
  index <- which(data\$count == max(data\$count[i:maxsearch]))
  mode <- data\$kmer_cov[index]
  
  xmax <- round(mode*3,-1)
  xmax
  
  peak_kmer_coverage = mode
  read_coverage_peak=peak_kmer_coverage*avg_read_length/(avg_read_length-kmer_size+1)
  read_coverage_peak
  est_genome_size=cum_read_length/read_coverage_peak
  est_genome_size
  
  pdf(paste(sample, \"-k\", kmer_size, \"-distribution.pdf\", sep=\"\"))
  plot(data\$kmer_cov[0:(xmax)], frequency[0:(xmax)], ylim=c(0,round(frequency[index]*2,2)), xlim=c(0,xmax), pch=20, 
       cex=0.5, xlab=\"kmer coverage\", ylab=\"frequency\", main=sample, axes=F)
  lines(data\$kmer_cov[0:xmax], frequency[0:xmax], type=\"b\")
  
  ymax <- 0
  ymax_decimals <- 0
  while (ymax == 0) {
    ymax_decimals = ymax_decimals+1
    ymax <- round(frequency[index]*2,ymax_decimals)
    #  print(ymax)
  }
  
  yticks <- 0
  yticks_decimals <- 0
  while (yticks == 0) {
    yticks_decimals = yticks_decimals+1
    yticks <- round(frequency[index]*2/4,yticks_decimals)
    #  print(yticks)
  }
  
  axis(1,at=seq(0,round(mode*3)+10,10),labels=T,las=2)
  axis(2,at=seq(0,round(frequency[index]*2,ymax_decimals),round((frequency[index]*2)/4,yticks_decimals)),labels=T)
  
  
  abline(v=peak_kmer_coverage,lty=2)
  legend(x=\"topright\", legend=c(paste(
    \" peak\", kmer_size, \"-mer coverage =\", mode, \"x\\\n\",
    \"peak read coverage =\", round(read_coverage_peak, 2), \"x\\\n\",
    \"est. genome size =\", round(est_genome_size/1e+06,1), \"Mb\"))
    ,bty=\"n\")
  box(which = \"plot\")
  dev.off()
  
  pdf(paste(sample, \"-k\", kmer_size, \"-distribution-full.pdf\", sep=\"\"))
  plot(data\$kmer_cov[0:maxsearch], frequency[0:maxsearch], pch=20, 
       cex=0.5, xlab=\"kmer coverage\", ylab=\"frequency\", main=sample, axes=T)
  lines(data\$kmer_cov[0:maxsearch], frequency[0:maxsearch], type=\"b\")
  abline(v=peak_kmer_coverage,lty=2)
  legend(x=\"topright\", legend=c(paste(
    \" peak\", kmer_size, \"-mer coverage =\", mode, \"x\\\n\",
    \"peak read coverage =\", round(read_coverage_peak, 2), \"x\\\n\",
    \"est. genome size =\", round(est_genome_size/1e+06,1), \"Mb\"))
    ,bty=\"n\")
  dev.off()
  
} else {
  pdf(paste(sample, \"-k\", kmer_size, \"-distribution-full.pdf\", sep=\"\"))
  plot(data\$kmer_cov[0:maxsearch], frequency[0:maxsearch], pch=20, 
       cex=0.5, xlab=\"kmer coverage\", ylab=\"frequency\", main=sample, axes=T)
  lines(data\$kmer_cov[0:maxsearch], frequency[0:maxsearch], type=\"b\")
  legend(x=\"topright\", legend=c(paste(\" Found no peak between coverage\", minsearch, \"and\", maxsearch, \"x \")))
  dev.off()
}
" > plot.freq.R
Rscript plot.freq.R

