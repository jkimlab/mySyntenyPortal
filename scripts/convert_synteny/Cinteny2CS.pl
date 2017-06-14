#!/usr/bin/perl

use strict;
use warnings;

my $in_file = shift;
my $out_file = shift;

#### Input example ###################################################
# # taxid chr startpos    endpos      taxid   chr startpos    endpos #
# # Dog(ref) vs Human(tar)                                           #  
# 9615    30  5325905 5211830 9606    15  32907691    33026870       #
######################################################################

my %Cinteny_num_hs = (); # save numeric chromosome ids
my %Cinteny_str_hs = (); # save string chromosome ids
open F,"$in_file";
while(<F>)
{
	chomp;
	next if /^#/;
	my @t = split(/\s+/);
	if($t[1] =~ /^(\d+)/)
	{
		$Cinteny_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[4].$t[5]:$t[6]-$t[7] +\n";
	}
	elsif($t[1] =~ /^chr(\d+)/i)
	{
		$Cinteny_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[4].$t[5]:$t[6]-$t[7] +\n";
	}
	else
	{
		$Cinteny_str_hs{$t[1]}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[4].$t[5]:$t[6]-$t[7] +\n";
	}
}
close F;

open W,">$out_file";
# print numeric chromosome synteny
my $block_id = 1;
foreach my $chr (sort {$a <=> $b} keys %Cinteny_num_hs)
{
	foreach my $str (sort {$a <=> $b} keys %{$Cinteny_num_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$Cinteny_num_hs{$chr}{$str}\n";
		$block_id++;
	}
}

# print string chromosome synteny
foreach my $chr (sort {$a cmp $b} keys %Cinteny_str_hs)
{
	foreach my $str (sort {$a cmp $b} keys %{$Cinteny_str_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$Cinteny_str_hs{$chr}{$str}\n";
		$block_id++;
	}
}

