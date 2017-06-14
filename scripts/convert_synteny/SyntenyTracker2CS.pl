#!/usr/bin/perl

use strict;
use warnings;

my $in_file = shift;
my $out_file = shift;

#### Input example ##########################################################
# Reference_genome    Ecaballus_chromosome    Ecaballus_start Ecaballus_end   Sscrofa_chromosome  Sscrofa_start   Sscrofa_end Sign    Target_genome   HSB Comments
# nominal nominal int int nominal int int int nominal int nominal           #
# Ecaballus   X   734575  993292  X   125485218   125801385       Sscrofa 1 #
# Ecaballus   X   2814668 48813138    X   2289528 52328700    +   Sscrofa 2 #
#############################################################################

my %SyntenyTracker_num_hs = (); # save numeric chromosome ids
my %SyntenyTracker_str_hs = (); # save string chromosome ids

open F,"$in_file";
while(<F>)
{
	chomp;
	next if /^Reference_genome/;
	next if /^nominal/;
	my @t = split(/\s+/);
	if($t[1] =~ /^(\d+)/)
	{
		if($t[7] eq "+" || $t[7] eq "-")
		{
			$SyntenyTracker_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[8].$t[4]:$t[5]-$t[6] $t[7]\n";
		}
		else
		{
			$SyntenyTracker_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[7].$t[4]:$t[5]-$t[6] +\n";
		}
	}
	elsif($t[1] =~ /^chr(\d+)/i)
	{
		if($t[7] eq "+" || $t[7] eq "-")
		{
			$SyntenyTracker_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[8].$t[4]:$t[5]-$t[6] $t[7]\n";
		}
		else
		{
			$SyntenyTracker_num_hs{$1}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[7].$t[4]:$t[5]-$t[6] +\n";
		}
	}
	else
	{
		if($t[7] eq "+" || $t[7] eq "-")
		{
			$SyntenyTracker_str_hs{$t[1]}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[8].$t[4]:$t[5]-$t[6] $t[7]\n";
		}
		else
		{
			$SyntenyTracker_str_hs{$t[1]}{$t[2]} = "$t[0].$t[1]:$t[2]-$t[3] +\n$t[7].$t[4]:$t[5]-$t[6] +\n";
		}
	}
}
close F;

open W,">$out_file";
# print numeric chromosome synteny
my $block_id = 1;
foreach my $chr (sort {$a <=> $b} keys %SyntenyTracker_num_hs)
{
	foreach my $str (sort {$a <=> $b} keys %{$SyntenyTracker_num_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$SyntenyTracker_num_hs{$chr}{$str}\n";
		$block_id++;
	}
}

# print string chromosome synteny
foreach my $chr (sort {$a cmp $b} keys %SyntenyTracker_str_hs)
{
	foreach my $str (sort {$a <=> $b} keys %{$SyntenyTracker_str_hs{$chr}})
	{
		print W ">$block_id\n";
		print W "$SyntenyTracker_str_hs{$chr}{$str}\n";
		$block_id++;
	}
}

