#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use FindBin '$Bin';
use Cwd 'abs_path';

my $proj_name = shift;

my $data_dir = "$Bin/../data/$proj_name";
$data_dir = abs_path($data_dir);

my $published_dir = "$Bin/../publish/$proj_name";

my $email = "";
open(F,"$data_dir/cur_state");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	if($arr[0] eq "Email"){
		$email = $arr[1];
	}
}
close(F);

if(!-d $published_dir){
	`cp -r $Bin/publish_template $published_dir`;
	`sed -i 's/WEBSITE_NAME/$proj_name/' $published_dir/htdocs/topbar.php`;
	`sed -i 's/EMAIL/$email/' $published_dir/htdocs/footer.php`;
	`ln -s $data_dir $published_dir/data`;
	`mkdir -p -m777 $published_dir/session`;
} else {
	`rm -rf $published_dir/session/*/cur_state`;
	`rm -rf $published_dir/session/*/circos/circos1`;
}

open(W,">$published_dir/session/.reset_state");
open(F,"$data_dir/cur_state");
while(<F>){
	chomp;
	if($_ =~ /^SC/){
		my @arr = split(/\s+/);
		`rm -rf $published_dir/session/circos`;
		`cp -r $data_dir/circos/circos$arr[2] $published_dir/session/circos`;
		`mv $published_dir/session/circos/circos$arr[2].info $published_dir/session/circos/circos1.info`;
		print W "SC\tcircos_num\t1\n";
	} else {
		print W "$_\n";
	}
}
close(F);
close(W);
