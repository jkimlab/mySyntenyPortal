#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use FindBin '$Bin';
use Getopt::Long qw(:config no_ignore_case);
use Sort::Key::Natural 'natsort';

my $synteny_F = "";
my $size_D = "";
my $out_D = "";
my $ref_name = "";
my $tar_name = "";
my $resolution = 0;
GetOptions(
	"s=s" => \$synteny_F,
	"ref|r=s" => \$ref_name,
	"tar|t=s" => \$tar_name,
	"res|m=i" => \$resolution,
	"size|z=s" => \$size_D,
	"o=s" => \$out_D,
);

`mkdir -p $out_D/tmp`;
`$Bin/syn2bed.pl -s $synteny_F -o $out_D/tmp`;

my %hs_syn = ();
my %hs_size = ();
if($resolution == 0){
	open(W,">$out_D/$ref_name.$tar_name.linear");
} else {
	open(W,">$out_D/$ref_name.$tar_name.$resolution.linear");
}

open(F,"$size_D/$ref_name.sizes");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	$hs_size{$ref_name}{$arr[0]} = $arr[1];
}
close(F);

open(F,"$size_D/$tar_name.sizes");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	$hs_size{$tar_name}{$arr[0]} = $arr[1];
}
close(F);

open(F,"$out_D/tmp/$ref_name.bed");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	$hs_syn{$arr[3]}{'ref'} = "$arr[0]\t$arr[1]\t$arr[2]\t$arr[5]";
}
close(F);

open(F,"$out_D/tmp/$tar_name.bed");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	$hs_syn{$arr[3]}{'tar'} = "$arr[0]\t$arr[1]\t$arr[2]\t$arr[5]";
}
close(F);

`$Bin/syn2bed.pl --merge -s $synteny_F -o $out_D/tmp`;
`cut -f1 $out_D/tmp/$ref_name.bed | sort -u > $out_D/tmp/$ref_name.chr`;
`$Bin/natsort.pl $out_D/tmp/$ref_name.chr`;
open(F,"$out_D/tmp/$ref_name.chr");
while(<F>){
	chomp;
	print W "#$ref_name\t$_\t$hs_size{$ref_name}{$_}\n";
}
close(F);

`cut -f1 $out_D/tmp/$tar_name.bed | sort -u > $out_D/tmp/$tar_name.chr`;
`$Bin/natsort.pl $out_D/tmp/$tar_name.chr`;
open(F,"$out_D/tmp/$tar_name.chr");
while(<F>){
	chomp;
	print W "#$tar_name\t$_\t$hs_size{$tar_name}{$_}\n";
}
close(F);

foreach my $syn_num (natsort keys %hs_syn){
	print W "$syn_num\t$hs_syn{$syn_num}{'ref'}|$syn_num\t$hs_syn{$syn_num}{'tar'}\n";
}
close(W);

`rm -rf $out_D/tmp`;
