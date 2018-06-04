
utgGenomeSize = 135m
merSize=22

#k-mer counting using meryl
#maximum total memory [Mb] used by meryl
merylMemory		=       700000
#number of threads
merylThreads            =       37

#read trimming settings
#specify overlapper for trimming (could be 'ovl', which is default of 'mer')
obtOverlapper		=	ovl
#number of of fragments to process per process (default=1000000); 
#mbtBatchsize = 1000000 uses about 10G of memory per process
#5x mbtConcurrency with mbtBatchSize=1000000 used more than 40G of memory 
mbtBatchSize		=	2000000
#number of threads per mer-based trimming process
mbtThreads		=	1
#Run this many mer-based trimming processes at the same time 
mbtConcurrency		=	37

#overlapper settings
#specify the size of the hash table per job (Hashbits 22 -> hashtable uses 864 Mb of memory, according to the Celera documentation)
ovlHashBits		=	22
#specify the number of bases loaded into the hashtable per job (100e6 will typically use about 1.2 Gb of memory) so with such setting a job will use a total of ~2.1 G of memory (865Mb+1.2Gb)
ovlHashBlockLength	=	1000000000
#number of jobs to run in parallel
ovlConcurrency		=	37
#number of threads per job
ovlThreads		=	1

#memory available for building overlap store in [Mb]
ovlStoreMemory          =       700000

#fragment correction
#number of reads processed by a process. Default 200000 seems to use about 1 G of memory for Miseq data
#2095m 1.7g 1496 R 263.3  0.2   1:36.10 correct-frags
frgCorrBatchSize	=	4000000
frgCorrThreads		=	1
frgCorrConcurrency	=	37
#according to the documentation an ovlCorrBatchSize of 400k uses (per process) about 750MB (Sanger data); For Miseq data it seems as if 400k batchsize uses ~400MB per process
#always only one thread per process
#1020m 931m 1400 R 99.6  0.1   1:00.96 correct-olaps
ovlCorrBatchSize	=	6000000
ovlCorrConcurrency	=	37

#specify unitig algorithm
unitigger=bogart
#bogart settings
#maximum memory usage in Gb
#18.3g  16g 1860 R 2000.0  1.6  13:10.78 bogart 
batMemory		=	700
batThreads		=	37

#consensus building
cnsConcurrency		=	37
