#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Getopt::Long qw(:config no_ignore_case);
use File::Basename;
use Cwd 'abs_path';
use FindBin '$Bin';

my $out_dir;
my $chainNet_dir;
my $ref_name;
my @tars;
my $resolution;
my @divs;

GetOptions (
		"chainNet|ch=s" => \$chainNet_dir,
		"ref|r=s" => \$ref_name,
		"res|m=s" => \$resolution,
		"tar|t=s{,}" => \@tars,
		"outdir|o=s" => \$out_dir,
);
@tars = split(/,/,join(',',@tars));

#### PATH ####
my $syn_src = "$Bin/../src/third_party/makeBlocks";
my $syn_make_f = "$syn_src/data/Makefile";
$out_dir = abs_path($out_dir);
#############

### 1. Making a config file ###
`mkdir -p $out_dir`;
open(CONFIG,">$out_dir/config.file");
print CONFIG ">netdir\n";
print CONFIG "$chainNet_dir\n";
print CONFIG "\n>chaindir\n";
print CONFIG "$chainNet_dir\n";
print CONFIG "\n>species\n";
print CONFIG "$ref_name\t0\t0\n";
foreach my $tar_name (@tars){
	print CONFIG "$tar_name\t1\t0\n";
}
print CONFIG "\n>resolution\n";
print CONFIG "$resolution\n";
close(CONFIG);
open(W,">$out_dir/Makefile");
print W "D = $syn_src\n";
close(W);
print 
`cat $syn_make_f >> $out_dir/Makefile`;
`make -C $out_dir 2> $out_dir/log.txt`;
`make tidy -C $out_dir`;
if(-f "$out_dir/synteny_blocks.txt"){
	my $tmp_dir = "$out_dir/tmp";
	`mkdir -p $tmp_dir`;
	`$Bin/syn2bed.pl --merge -s $out_dir/synteny_blocks.txt -o $tmp_dir`;
	`cut -f1 $tmp_dir/$ref_name.bed | sort -u > $out_dir/$ref_name.chr`;
	foreach my $tar_name (@tars){
		`cut -f1 $tmp_dir/$tar_name.bed | sort -u > $out_dir/$tar_name.chr`;
		`$Bin/natsort.pl $out_dir/$tar_name.chr`;
	}
	`rm -rf $tmp_dir`;
} else {
	print STDERR "    => No synteny blocks\n";
	`rm -rf $out_dir`;
}
