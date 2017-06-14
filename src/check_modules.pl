#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use FindBin '$Bin';
use lib "$Bin/lib/";


BEGIN {
	require Check::Modules;
	if(!check_modules()){
	}
	else{
		print "All perl modules exists!!\n";
	}
}
