#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use FindBin '$Bin';
use Sort::Key::Natural 'natsort';
use File::Basename;
use Getopt::Long qw(:config no_ignore_case);

my $synteny_F;
my $out_dir = "./";
my $sort;
my $merge;
my $help;
my $bed_tools_cmd = "$Bin/../src/third_party/bedtools/bin";

GetOptions (
	"syn|s=s" => \$synteny_F,
	"sort" => \$sort,
	"merge" => \$merge,
	"outdir|o=s" => \$out_dir,
	"help|h" => \$help,
);

if(!$synteny_F || $help){
	print STDERR "
Usage: syn2bed.pl <parameter(optional)> -s [Conserved.Segments file]

[Parameters (optional)]
  --sort  sorting bedfiles
  --merge sorting&merging bedfiles

";
	exit(1);
}

my %hs;
my $syn_num = 0;
open(F,"$synteny_F");
while(<F>)
{
	chomp;
	if($_ eq ""){next;}
	if($_ =~ /^>(\S+)/){
		$syn_num = $1;
		next;
	}

	my @arr = split(/\s+|\:/);
        my @arr2 = split(/\-/,$arr[1]);
        my @arr3 = split(/\./,$arr[0]);
        my $chr_name = "";
        for(my $i=1;$i<=$#arr3;$i++){
                if($i == 1){
                        $chr_name = $arr3[$i];
                } else {
                        $chr_name .= ".$arr3[$i]";
                }
        }        $hs{$arr3[0]}{$syn_num} = "$chr_name\t$arr2[0]\t$arr2[1]\t$syn_num\t0\t$arr[2]";
}
close(F);

foreach my $spc (keys %hs)
{
	open(W,">$out_dir/tmp.$spc.bed");
	foreach my $num (natsort keys %{$hs{$spc}})
	{
		print W "$hs{$spc}{$num}\n";
	}
	close(W);

	if($merge){
		`$bed_tools_cmd/bedtools sort -i $out_dir/tmp.$spc.bed > $out_dir/tmp.$spc.sorted.bed`;
		`$bed_tools_cmd/bedtools merge -i $out_dir/tmp.$spc.sorted.bed > $out_dir/$spc.bed`;
	} elsif($sort){
		`$bed_tools_cmd/bedtools sort -i $out_dir/tmp.$spc.bed > $out_dir/$spc.bed`;
	} else {
		`cp $out_dir/tmp.$spc.bed $out_dir/$spc.bed`;
	}

	`rm -f $out_dir/tmp.*`;
}

