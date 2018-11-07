#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use Sort::Key::Natural qw(natsort);
use FindBin '$Bin';
## Required
my $in_gene_annot;
my $in_synteny_block;
my $ref_name;
my $tar_name;
my $resolution = 0;
my $out_dir;
my $help;

## Additional
my %hs_gene_info = ();
my $gene_id = "";
my $gene_name = "";

my $bed_tools_cmd = "$Bin/../src/third_party/bedtools/bin";


## Get options
GETOPTS();
## GTF file to BED file
EXT_GENE();
## BEDtools: sort
`$bed_tools_cmd/bedtools sort -i $out_dir/tmp/p.bed > $out_dir/tmp/sort.p.bed`;
`$bed_tools_cmd/bedtools sort -i $out_dir/tmp/m.bed > $out_dir/tmp/sort.m.bed`;
`rm -rf $out_dir/tmp/p.bed $out_dir/tmp/m.bed`;
## Make synteny.bed file
EXT_SYN();
## BEDtools: intersect
`$bed_tools_cmd/bedtools intersect -wa -wb -a $out_dir/tmp/synteny.bed -b $out_dir/tmp/sort.p.bed > $out_dir/tmp/intersection.p.bed`;
`$bed_tools_cmd/bedtools intersect -wa -wb -a $out_dir/tmp/synteny.bed -b $out_dir/tmp/sort.m.bed > $out_dir/tmp/intersection.m.bed`;
`cut -f4,5,6,7,8 $out_dir/tmp/intersection.m.bed > $out_dir/tmp/cut.inter.m.bed`;
`cut -f4,5,6,7,8 $out_dir/tmp/intersection.p.bed > $out_dir/tmp/cut.inter.p.bed`;
`sort -k2n,2 -k3n,3 -k4nr,4 $out_dir/tmp/cut.inter.m.bed > $out_dir/tmp/sort.cut.inter.m.bed`;
`sort -k2n,2 -k3n,3 -k4nr,4 $out_dir/tmp/cut.inter.p.bed > $out_dir/tmp/sort.cut.inter.p.bed`;
## Make final output
MAKE_OUTPUT("$out_dir/tmp/sort.cut.inter.p.bed", "$out_dir/tmp/sort.cut.inter.m.bed");
## Remove temporary directory
#`rm -rf $out_dir/tmp`;

sub MAKE_OUTPUT{
	if($resolution == 0){
		open(FOUT, ">$out_dir/$ref_name.$tar_name.geneTrack");
	} else {
		open(FOUT, ">$out_dir/$ref_name.$tar_name.$resolution.geneTrack");
	}
	my $p_bed = shift(@_);
	open(FBED, "$p_bed");
	my @track = (1,2,3);
	my $i = -1;
	while(<FBED>){
		chomp;
		$i++;
		my @t = split(/\t/,$_);
		my ($chr, $start, $end, $syn, $strand) = ($t[1], $t[2], $t[3], $t[0], "+");
		my $index = $i%3;
		my $track = $track[$index];
		my ($gene_id, $gene_name) = split(/,/,$t[4]);
		print FOUT "$chr\t$track\t$gene_id\t$start\t$end\t$syn\t$gene_name\t$strand\n";
	}
	close(FBED);

	my $m_bed = shift(@_);
	open(FBED, "$m_bed");
	@track = (4,5,6);
	$i = -1;
	while(<FBED>){
		chomp;
		$i++;
		my @t = split(/\t/,$_);
		my ($chr, $start, $end, $syn, $strand) = ($t[1], $t[2], $t[3], $t[0], "-");
		my $index = $i%3;
		my $track = $track[$index];
		my ($gene_id, $gene_name) = split(/,/,$t[4]);
		print FOUT "$chr\t$track\t$gene_id\t$start\t$end\t$syn\t$gene_name\t$strand\n";
	}
	close(FBED);
	close(FOUT);
}

sub EXT_SYN{
	open(FINSYN, $in_synteny_block);
	open(FOUTSYN, ">$out_dir/tmp/synteny.bed");
	while(<FINSYN>){
		chomp;
		my @t = split(/\t/,$_);
		my ($chr, $start, $end, $syn) = ("", $t[1], $t[2], $t[3]);
		if($t[0] =~ /^chr/){ $chr = substr($t[0],3); }
		else{ $chr = $t[0]; }
		print FOUTSYN "$chr\t$start\t$end\t$syn\n";
	}
	close(FINSYN);
	close(FOUTSYN);
}

sub EXT_GENE{
	`rm -f $out_dir/tmp/*.bed`;
	open(FPLUS, ">$out_dir/tmp/p.bed");
	open(FMINUS, ">$out_dir/tmp/m.bed");
	if($in_gene_annot =~ /\.gz$/){ open(FGTF, "gunzip -c $in_gene_annot|"); }
	else{ open(FGTF, "$in_gene_annot"); }
	while(<FGTF>){
		chomp;
		if($_ =~ /^#/){ next; }
		my @t = split(/\t/,$_);
		if($t[2] ne "gene"){ next; }
		($gene_id, $gene_name) = ("", "");
		my @annot = split(/; /,$t[8]);
		foreach my $info (@annot){
			if($info =~ /^gene_id/){
				my @g_id = split(/\"/,$info);
				$gene_id = $g_id[1];
			}
			if($info =~ /^gene_name/){
				my @g_name = split(/\"/,$info);
				$gene_name = $g_name[1];
			}
			if($gene_name ne "" && $gene_id ne ""){ last; }
		}
		if($t[6] eq "+"){ print FPLUS "$t[0]\t$t[3]\t$t[4]\t$gene_id,$gene_name\n"; }
		else{ print FMINUS "$t[0]\t$t[3]\t$t[4]\t$gene_id,$gene_name\n"; }
	}
	close(FGTF);
}

sub GETOPTS{
	my $status = GetOptions(
		"r=s" => \$ref_name,
		"t=s" => \$tar_name,
		"m=i" => \$resolution,
		"gtf=s" => \$in_gene_annot,
		"syn=s" => \$in_synteny_block,
		"out=s" => \$out_dir,
		"h|help" => \$help,
	);
	if($status != 1 || !defined($in_gene_annot) || !defined($in_synteny_block) || !defined($out_dir) || $help){ PRINTHELP(); }
	`mkdir -p $out_dir/tmp`;
}

sub PRINTHELP{
	my $src = basename($0);
	print "Usage: $src -gtf <GTF file> -syn <synteny file> -r <ref_name> -t <tar_name> -m <resolution> -out <out dir>\n";
	print "\t-gtf : (required, string) Input gene annotation GTF file\n";
	print "\t-syn : (required, string) Input synteny block file (.bed)\n";
	print "\t-r : (required, string) Reference name\n";
	print "\t-t : (required, string) Target name\n";
	print "\t-m : (required, string) Resolution\n";
	print "\t-out : (required, string) Output directory\n";
	print "\t-h|-help : Print this page\n";
	exit;
}
