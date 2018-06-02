setwd("/home/478358/WORKING/G_turnbulli/kmc/G14/trimmed")

data = read.table("G14-trimmed-k21.hist.txt", sep="\t", col.names=c("kmer_cov","count"))

sample="G14-trimmed"
kmer_size=21
cum_read_length=9746801644
avg_read_length=125.65

minsearch=5
maxsearch=200

frequency=data$count/sum(data$count)

for (i in minsearch:maxsearch+1){
  if ( max(data$count[i:maxsearch]) != data$count[i]){
    if ( data$count[i-1] > data$count[i] & data$count[i] < data$count[i+1] & max(data$count[i:maxsearch])/data$count[i] >= 2 ){
      if ( (which(data$count == max(data$count[i:maxsearch])) - i) >= 5 ){
        break
      }
    }
  }
}

#if ( which(data$count == max(data$count[minsearch:maxsearch])) > minsearch ){
if (i <= maxsearch){
  #find peak
#  valley <- i-1
#  index <- which(data$count == max(data$count[valley:maxsearch]))
  index <- which(data$count == max(data$count[i:maxsearch]))
  mode <- data$kmer_cov[index]
  
  xmax <- round(mode*3,-1)
  xmax
  
  peak_kmer_coverage = mode
  read_coverage_peak=peak_kmer_coverage*avg_read_length/(avg_read_length-kmer_size+1)
  read_coverage_peak
  est_genome_size=cum_read_length/read_coverage_peak
  est_genome_size
  
  pdf(paste(sample, "-k", kmer_size, "-distribution.pdf", sep=""))
  plot(data$kmer_cov[0:(xmax)], frequency[0:(xmax)], ylim=c(0,round(frequency[index]*2,2)), xlim=c(0,xmax), pch=20, 
       cex=0.5, xlab="kmer coverage", ylab="frequency", main=sample, axes=F)
  lines(data$kmer_cov[0:xmax], frequency[0:xmax], type="b")
  
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
  legend(x="topright", legend=c(paste(
    " peak", kmer_size, "-mer coverage =", mode, "x\n",
    "peak read coverage =", round(read_coverage_peak, 2), "x\n",
    "est. genome size =", round(est_genome_size/1e+06,1), "Mb"))
    ,bty="n")
  box(which = "plot")
  dev.off()
  
  pdf(paste(sample, "-k", kmer_size, "-distribution-full.pdf", sep=""))
  plot(data$kmer_cov[0:maxsearch], frequency[0:maxsearch], pch=20, 
       cex=0.5, xlab="kmer coverage", ylab="frequency", main=sample, axes=T)
  lines(data$kmer_cov[0:maxsearch], frequency[0:maxsearch], type="b")
  abline(v=peak_kmer_coverage,lty=2)
  legend(x="topright", legend=c(paste(
    " peak", kmer_size, "-mer coverage =", mode, "x\n",
    "peak read coverage =", round(read_coverage_peak, 2), "x\n",
    "est. genome size =", round(est_genome_size/1e+06,1), "Mb"))
    ,bty="n")
  dev.off()
  
} else {
  pdf(paste(sample, "-k", kmer_size, "-distribution-full.pdf", sep=""))
  plot(data$kmer_cov[0:maxsearch], frequency[0:maxsearch], pch=20, 
       cex=0.5, xlab="kmer coverage", ylab="frequency", main=sample, axes=T)
  lines(data$kmer_cov[0:maxsearch], frequency[0:maxsearch], type="b")
  legend(x="topright", legend=c(paste(" Found no peak between coverage", minsearch, "and", maxsearch, "x ")))
  dev.off()
}

