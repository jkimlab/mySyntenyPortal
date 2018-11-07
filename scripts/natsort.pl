#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Sort::Key::Natural 'natsort';
use File::Basename;


my $file = shift;
my $tmp_file = "$file.tmp";
`mv $file $tmp_file`;
my %hs;
open(F,"$tmp_file");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	$hs{$arr[0]} = $_;
}
close(F);

open(W,">$file");
foreach my $key (natsort keys %hs){
	print W "$hs{$key}\n";
}
close(W);

`rm -f $tmp_file`;
