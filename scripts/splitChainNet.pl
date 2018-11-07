#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Cwd 'abs_path';
use File::Basename;
use Getopt::Long qw(:config no_ignore_case);
use FindBin '$Bin';

my $chain_F;
my $net_F;
my $gz_flag = 1;
my $out_dir = ".";
my $help;

GetOptions (
		"chain|c=s" => \$chain_F,
		"net|n=s" => \$net_F,
		"gz:i" => \$gz_flag,
		"out_dir|o=s" => \$out_dir,
		"help|h" => \$help,
);

if($help||!$chain_F||!$net_F){
	print "splitChainNet.pl --chain [chain] --net [net] --gz (Compressed inputs .gz) -o [out_dir]\n";
	exit(1);

}

`mkdir -p $out_dir`;

my $base_chain = basename($chain_F);
my $base_net = basename($net_F);
my $makeBlocks_src = "$Bin/../src/third_party/makeBlocks";

`cp $chain_F $out_dir`;
`cp $net_F $out_dir`;

if($gz_flag == 0){
	`gunzip $out_dir/$base_chain`;
	`gunzip $out_dir/$base_net`;
	$base_chain = basename($chain_F,".gz");
	$base_net = basename($net_F,".gz");
}

open(F,"$out_dir/$base_net");
open(W,">$out_dir/$base_net.tmp");
while(<F>)
{
	chomp;
	if($_ =~ /^#/){next;}
	print W "$_\n";
}
close(F);
close(W);

`mkdir -p $out_dir/chain $out_dir/net`;
`$makeBlocks_src/splitChain -i $out_dir/$base_chain -o $out_dir/chain`;
`$makeBlocks_src/splitNet -i $out_dir/$base_net.tmp -o $out_dir/net`;
`rm -f $out_dir/all.chain $out_dir/all.net $out_dir/all.net.tmp`;
