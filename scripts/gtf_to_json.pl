#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use FindBin qw($Bin);
use Cwd 'abs_path';
use Getopt::Long;
use File::Basename;
use JSON;

## Required
my $in_gtf;
my $size;
my $out_json;
my $temp_dir;
my $help;

## Additional variables
my %hs_annot_type = ();
my %hs_size = ();

## Main
GETOPTS();
READ_SIZE();
EXT_ID_NAME();
MAKE_DATA_FILE();
MAKE_JSON();

## Functions
sub MAKE_JSON{
	my %hs_data = ();
	my @arr_info = ();
	my $gene_name_index = "";
	open(FDATA, "$temp_dir/annotation_data");
	while(<FDATA>){
		chomp;
		if($_ =~ /^#(.+)/){
			my $info = $1;
			@arr_info = split(/\t/,$info);
			for(my $i = 0; $i <= $#arr_info; $i++){
				if($arr_info[$i] eq "gene_name"){
					$gene_name_index = $i;
				}
			}
			if($gene_name_index eq ""){
				die "Error. There is no gene name column.\n";
			}
		}
		else{
			my @temp = split(/\t/,$_);
			my $gene_name = $temp[$gene_name_index];
			for (my $i = 0; $i <= $#temp; $i++){
				my $id = $temp[$i];
				my $name = $arr_info[$i];

				next if ($id eq "");
				if (!exists($hs_data{$gene_name}{$name})){
					push(@{$hs_data{$gene_name}{$name}},$id);
				}
				else{
					if ($hs_data{$gene_name}{$name} ne ""){
						my $match = 0;
						foreach my $ex_id (@{$hs_data{$gene_name}{$name}}){
							if ($ex_id eq $id){
								$match++;
							}
						}
						if ($match == 0){
							push(@{$hs_data{$gene_name}{$name}},$id);
						}
					}
					else{
						push(@{$hs_data{$gene_name}{$name}},$id);
					}
				}
			}
		}
	}
	close(FDATA);
	foreach my $x (keys %hs_data){
		foreach my $y (@arr_info){
			if(!exists($hs_data{$x}{$y})){
				$hs_data{$x}{$y} = "";
			}
			else{
				if ($#{$hs_data{$x}{$y}} == 0){
					$hs_data{$x}{$y} = ${$hs_data{$x}{$y}}[0];
				}
			}
		}
	}
    my %hash_json = ();
	foreach my $x (keys %hs_data){
		push(@{$hash_json{"id_convert"}},$hs_data{$x});
	}
	my $data_json = encode_json \%hash_json;
	open(FOUT,">$out_json");
	print FOUT $data_json;
	close(FOUT);
}

sub MAKE_DATA_FILE{
	open(FGTF, "$temp_dir/gene_and_transcript.gtf");
	open(FOUT, ">$temp_dir/annotation_data");
	$hs_annot_type{"chr"} = 1;
	my @annot_type = keys(%hs_annot_type);
	print FOUT "#$annot_type[0]";
	for(my $i = 1; $i <= $#annot_type; $i++){
		print FOUT "\t$annot_type[$i]";
	}
	print FOUT "\n";
	while(<FGTF>){
		my %hs_temp_data = ();
		chomp;
		my $data_string = "";
		my @t = split(/\t/,$_);
		$hs_temp_data{"chr"}=$t[0];
		$t[8] =~ s/; /;/g;
		my @annot = split(/;/,$t[8]);
		foreach my $ano (@annot){
			my @data = split(/\s+/,$ano);
			if(exists $hs_annot_type{$data[0]}){
				my @val = split(/\"/,$data[1]);
				$hs_temp_data{$data[0]} = $val[1];
			}
		}
		foreach my $ano (@annot_type){
			if(exists $hs_temp_data{$ano}){ 
				print FOUT "$hs_temp_data{$ano}"; 
			}
			print FOUT "\t";
		}
		print FOUT "\n";
	}
	close(FGTF);
	close(FOUT);
}

sub EXT_ID_NAME{
	if($in_gtf =~ /gz/){ open(FGTF, "gunzip -c $in_gtf|"); }
	else{ open(FGTF, "$in_gtf"); }
	open(FOUT, ">$temp_dir/gene_and_transcript.gtf");
	while(<FGTF>){
		chomp;
		if($_ =~ /^#/){ next; }
		my @t = split(/\t/,$_);
		if($t[2] ne "gene" && $t[2] ne "transcript"){ next; }
		if(!exists $hs_size{$t[0]} && !exists $hs_size{"chr$t[0]"}){ next; }
		if(!exists $hs_size{$t[0]} && exists $hs_size{"chr$t[0]"}){
			$t[0] = "chr$t[0]";
		}
		$t[8] =~ s/; /;/g;
		foreach my $data (@t){
			print FOUT "$data\t";
		}
		print FOUT "\n";
		my @annot = split(/;/,$t[8]);
		foreach my $info (@annot){
			if($info =~ /_id/ || $info =~ /_name/){
				my @annot_type = split(/\s/,$info);
				$hs_annot_type{$annot_type[0]} = 1;
			}
		}
	}
	close(FGTF);
	my @annot_type = keys(%hs_annot_type);
	if($#annot_type == -1){ die "There is no annotation information.\n"; }
	close(FOUT);
}

sub READ_SIZE{
	open(FSIZE, "$size");
	while(<FSIZE>){
		chomp;
		my @t = split(/\s+/,$_);
		$hs_size{$t[0]} = $t[1];
	}
	close(FSIZE);
}

sub GETOPTS{
	my $status = GetOptions(
		"i=s" => \$in_gtf,
		"s=s" => \$size,
		"o=s" => \$out_json,
		"t=s" => \$temp_dir,
		"h|help" => \$help,
	);
	if($status != 1 || !defined($in_gtf) || !defined($out_json) || !defined($size) || $help){ PRINTHELP(); }
	if(!defined($temp_dir)){ $temp_dir = "./tmp"; }
	`mkdir -p $temp_dir`;
}

sub PRINTHELP{
	my $src = basename($0);
	print "Usage: $src -i <GTF file> -o <out Json file name>\n";
	print "\t-i <string> Input gene annotation GTF file (required).\n";
	print "\t-s <string> Input sequence size file (required).\n";
	print "\t-o <string> Output Json file name (required).\n";
	print "\t-t <string> A temporary directory. (default is ./tmp)\n";
	print "\t-h|-help Print this page.\n";
	exit;
}
