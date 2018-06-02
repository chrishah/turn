#!/usr/bin/perl

use strict;
use warnings;

my $file = $ARGV[0];
my ($in_fh,$key,$val);
my %hash;

if (!$file){
	print "\nyou have to provide fastq or fastq.gz file\n";
	exit;
}

if ($file =~ /gz$/){
	open $in_fh, "gunzip -dc $file |" or warn "Cannot read $file: $!";
}
else{ 
	open $in_fh, $file or warn "Cannot read $file: $!";
}

my $index = 1;
while (<$in_fh>){
	if ($index % 4 ==1){
		chomp;
		$_ =~ s/^@//g;
		($key, $val) = split /\//;
		$hash{$key} .= exists $hash{$key} ? "$val" : $val;
	}	
	$index++;
}

open (FH_pairs,">list.pe") or die $!;
open (FH_singletons,">list.se") or die $!;
for (keys %hash){
	my @ID = split ("",$hash{$_});
#	print "$_: ".scalar @ID."\n";
	if (@ID == 2){
		print FH_pairs "$_/1\n$_/2\n";
	}
	elsif (@ID == 1){
		print FH_singletons "$_/$ID[0]\n";
	}
}



