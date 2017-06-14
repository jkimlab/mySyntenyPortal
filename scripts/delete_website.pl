#!/usr/bin/perl

use strict;
use warnings;
use FindBin '$Bin';

my $proj_name = shift;

`cp $Bin/../htdocs/path_info.txt $Bin/../htdocs/.path_tmp`;

my $flag = 0;
open(W,">$Bin/../htdocs/path_info.txt");
open(F,"$Bin/../htdocs/.path_tmp");
while(<F>){
	chomp;
	if($_ =~ /^>/){
		if($_ eq ">$proj_name"){
			$flag = 1;
		} else {
			$flag = 0;
		}
	}

	if($flag == 0){
		print W "$_\n";
	}
}
close(F);
close(W);

if(-d "$Bin/../data/$proj_name"){
	`rm -rf $Bin/../data/$proj_name`;
}

if(-d "$Bin/../publish/$proj_name"){
	`rm -rf $Bin/../publish/$proj_name`;
}
