#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

my $in_file = shift;
my $out_file = shift;

#### Input example ######################################################
# File name format: Q[query species]_T[target species].satsuma.out      #
# chrX:0-800000   1   121 chrX:0-1000000  1315    1435    0.608333    + #
# chrX:0-800000   235 415 chrX:0-1000000  1547    1727    0.605556    + #
# chrX:0-800000   463 581 chrX:0-1000000  1829    1947    0.533898    + #
#########################################################################

my ($ref,$tar) = ("","");
if($in_file =~ /Q(\w+)_T(\w+)/)
{
	$ref = $1;
	$tar = $2;
}

my %satsuma_num_hs = (); # save numeric chromosome ids
my %satsuma_str_hs = (); # save string chromosome ids
open F,"$in_file";
while(<F>)
{
	chomp;
	next if /^#/;
	my @t = split(/\s+/);
	if($t[1] =~ /(\d+)/)
	{
		$satsuma_num_hs{$1}{$t[2]} = "$ref.$t[0]:$t[1]-$t[2] +\n$tar.$t[3]:$t[4]-$t[5] $t[7]\n";
	}
	elsif($t[1] =~ /chr(\d+)/i)
	{
		$satsuma_num_hs{$1}{$t[2]} = "$ref.$t[0]:$t[1]-$t[2] +\n$tar.$t[3]:$t[4]-$t[5] $t[7]\n";
	}
	else
	{
		$satsuma_num_hs{$t[1]}{$t[2]} = "$ref.$t[0]:$t[1]-$t[2] +\n$tar.$t[3]:$t[4]-$t[5] $t[7]\n";
	}
}
close F;

open W,">$out_file";
# print numeric chromosome synteny
my $block_id = 1;
foreach my $chr (sort {$a <=> $b} keys %satsuma_num_hs)
{
	foreach my $str (sort {$a <=> $b} keys %{$satsuma_num_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$satsuma_num_hs{$chr}{$str}\n";
		$block_id++;
	}
}

# print string chromosome synteny
foreach my $chr (sort {$a cmp $b} keys %satsuma_str_hs)
{
	foreach my $str (sort {$a cmp $b} keys %{$satsuma_str_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$satsuma_str_hs{$chr}{$str}\n";
		$block_id++;
	}
}

