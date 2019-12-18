#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use File::Basename;
use Cwd 'abs_path';
use Sort::Key::Natural 'natsort';
use FindBin '$Bin';
use Getopt::Long qw(:config no_ignore_case);


my $outdir = ".";
my $prefix = "circos";
my $synteny_path = "";
my $info_F = "";
my $size_dir = "";
my $resolution = 0;

GetOptions(
	"outdir|o=s" => \$outdir,
	"syn|s=s" => \$synteny_path,
	"info|i=s" => \$info_F,
	"size_dir|z=s" => \$size_dir,
);

################ Path
$outdir = abs_path($outdir);
my $circos_dir = "$Bin/../src/third_party/circos";
my $circos_input = "$outdir/circos_inputs";
$synteny_path = abs_path($synteny_path);

`mkdir -p $outdir`;
`mkdir -p $circos_input`;
`mkdir -p $circos_input/karyotype`;
`mkdir -p $circos_input/confs`;

######### Species/Assembly name
my %chr_used = ();
my %cytoband = ();
my %spc_name = ();
my $flag = 0;
my $spc_num = 0;
open(F,"$info_F");
while(<F>){
	chomp;
	my @arr = split(/\s+/);
	if($_ =~ /^Resolution/){
		if($arr[1] eq ""){
			$resolution = 0;
		} else {
			$resolution = $arr[1];
		}
		next;
	}
	if($_ =~ /^Cytoband/){
		$cytoband{$arr[1]} = $arr[2];
		next;
	}

	if($arr[2] eq "all" || $arr[2] eq "All"){
		open(F2,"$size_dir/$arr[1].sizes");
			while(my $line = <F2>){
			chomp($line);
			my @size_line = split(/\s+/,$line);
			my $chr = $size_line[0];
			my $chr_n;
			if($chr =~ /^chr/){
				$chr_n = substr($chr,3);
			} else {
				$chr_n = $chr;
			}
			$chr_used{$arr[0]}{$chr_n} = 0;
		}
	} else {
		my @arr_chr = split(/,/,$arr[2]);
		foreach my $chr (@arr_chr){
			my $chr_n;
			if($chr =~ /^chr/){
				$chr_n = substr($chr,3);
			} else {
				$chr_n = $chr;
			}
			$chr_used{$arr[0]}{$chr_n} = 0;
		}
	}

	$spc_name{$arr[0]} = $arr[1];
	$spc_num = $arr[0];
	
}
close(F);

my %scaf_order=(); #{spc_num}{order(0,1,2,,)}=chr;
my %ID=(); #{spc_num}=rf,aa,ab,ac,,,;
my %ref_chr=(); #{chr}=1;

my @alphabet = ("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z");

my $spc_num_tmp=0;
foreach my $first (@alphabet){
	foreach my $second (@alphabet){
		$ID{$spc_num_tmp} = $first.$second;
		$spc_num_tmp++;
	}
}

################# 1. Colors & karyotype #####################
my %color = (); #value = color 
my %chr_size=();#{spc_num}{chr}=size;
my %chr_total=();#{spc_num}=total size;

my $chr_flag = 1;
foreach my $spc_order (natsort keys %spc_name){
	$chr_total{$spc_order}=0;
	my $scaf_order_num = 0;
	open(S,"$size_dir/$spc_name{$spc_order}.sizes");
	while(<S>){
		chomp;
		my @tmp = split(/\t/,$_);
		my $chr_n = "";
		if($tmp[0] =~ /^chr/ && $tmp[0] !~ /_/){
			$chr_n = substr($tmp[0],3);
			$chr_flag = 0;
		}else{
			$chr_n = $tmp[0];
		}

		if(!exists $chr_used{$spc_order}{$chr_n}){next;}
		if($spc_order == 0){$ref_chr{$chr_n}=1;}
		$chr_size{$spc_order}{$chr_n}=$tmp[1];
		$chr_total{$spc_order} += $tmp[1];
		$scaf_order{$spc_order}{$scaf_order_num} = $chr_n;
		$scaf_order_num++;
	}
	close(S);
}

my $i = 0;
foreach my $c (natsort keys %ref_chr){
	if($chr_flag == 0){
		if($c =~ /^\d+$/){
			if($c > 373){$c = ($c % 373)+1;}
			$color{$c} = "mySyntenyPortal".($c);
			$i++;
		} else {
			$color{$c} = "mySyntenyPortal".($i+1);
			$i++;
			if($i > 372){$i = 0;}
		}
	} else {
		$color{$c} = "mySyntenyPortal".($i+1);
		$i++;
		if($i > 372){$i = 0;}
	}

}

open(K,">$circos_input/karyotype/$prefix.karyotype.0.txt");
foreach my $k (natsort keys %{$chr_size{0}}){
	print K "chr - $ID{0}$k $k 0 $chr_size{0}{$k} $color{$k}\n";
}

if(exists $cytoband{$spc_name{0}}){
	open(CY,$cytoband{$spc_name{0}});
	while(<CY>){
		chomp;
		if($_ !~ /^#/){
			my @tmp = split(/\t/,$_);
			if($tmp[0] =~ /^chr/){
				my @tmp2 = split(/chr/,$tmp[0]);
				if($tmp[3] !~ /^\w/){
					$tmp[3] = "p";
				}
				if(exists $chr_size{0}{$tmp2[1]}){
					print K "band $ID{0}$tmp2[1] $tmp[3] $tmp[3] $tmp[1] $tmp[2] $tmp[4]\n";
				}
			}
		}
	}
	close CY;
}
close K;

foreach my $spc_order (natsort keys %spc_name){
	if($spc_order == 0){next;}
	open(K,">$circos_input/karyotype/$prefix.karyotype.$spc_order.txt");
	foreach my $k (natsort keys %{$chr_size{$spc_order}}){
		print K "chr - $ID{$spc_order}$k $k 0 $chr_size{$spc_order}{$k} white\n";
	}

	if(exists $cytoband{$spc_name{$spc_order}}){
		open(CY,$cytoband{$spc_name{$spc_order}});
		while(<CY>){
			chomp;
			if($_ !~ /^#/){
				my @tmp = split(/\t/,$_);
				if($tmp[0] =~ /^chr/){
					my @tmp2 = split(/chr/,$tmp[0]);
					if($tmp[3] !~ /^\w/){
						$tmp[3] = "p";
					}
					if(exists $chr_size{$spc_order}{$tmp2[1]}){
						print K "band $ID{$spc_order}$tmp2[1] $tmp[3] $tmp[3] $tmp[1] $tmp[2] $tmp[4]\n";
					}
				}
			}
		}
		close CY;
	}
	close K;
}

######### 2. (.link) (.highlight) (.txt)##############
open(LINK,">$circos_input/$prefix.link");
open(HIGHLIGHT,">$circos_input/$prefix.highlight");
my $ref_name = $spc_name{0};
for(my $i = 1;$i <= $spc_num;$i++){
	my $tar_name = $spc_name{$i};
	my $synteny_F;

	if(-f "$synteny_path/$ref_name/$tar_name/$resolution/synteny_blocks.txt"){
		$synteny_F = "$synteny_path/$ref_name/$tar_name/$resolution/synteny_blocks.txt";
	} elsif(-f "$synteny_path/$ref_name.$tar_name.synteny"){
		$synteny_F = "$synteny_path/$ref_name.$tar_name.synteny";
	}

	open(SYN,"$synteny_F");
	while(<SYN>){
		chomp;
		if($_ =~ /^>/){
			my $a = $_;
			my $line_ref = <SYN>;
			chomp($line_ref);
			my @line_ref_split = split(/\W/,$line_ref);
			my $ref_name = $line_ref_split[0];
			my $ref_chr = "";
			if($line_ref_split[1] =~ /chr/){
				my @tmp = split(/chr/,$line_ref_split[1]);
				$ref_chr = $tmp[1];
			}else{
				$ref_chr = $line_ref_split[1];
			}

			if(!exists $chr_used{0}{$ref_chr}){next;}
			my $ref_s = $line_ref_split[2];
			my $ref_e = $line_ref_split[3];
	
			my $line_tar = <SYN>;
			chomp($line_tar);
			my $dir = "";
			if($line_tar =~ /\+/){$dir = "+";} else {$dir = "-";}
			my @line_tar_split = split(/\.|:|\s+/,$line_tar);
			my $tar_name = $line_tar_split[0];
			$line_tar_split[1] =~ s/chr//;
			my $tar_chr = $line_tar_split[1];
			my @tmp2 = split(/-/,$line_tar_split[2]);
			my $tar_s = $tmp2[0];
			my $tar_e = $tmp2[1];

			print LINK "$ID{0}$ref_chr $ref_s $ref_e $ID{$i}$tar_chr $tar_s $tar_e color=$color{$ref_chr}_a3\n";
			if((exists $chr_size{0}{$ref_chr})&&(exists $chr_size{$i}{$tar_chr})){
				print HIGHLIGHT "$ID{$i}$tar_chr $tar_s $tar_e fill_color=$color{$ref_chr}_a2\n";
			}
		}
	}
}
close(LINK);
close(SYN);
close(HIGHLIGHT);

my %gap=();
for(my $i=0;$i <= $spc_num;$i++){
	my $chr_number = keys %{$chr_size{$i}};
	my $chr_angle= 360/($spc_num+1) - 4.32 -$chr_number;
	$gap{$i}=int($chr_total{$i}*1.08/$chr_angle);
}

open(ON,">$circos_input/$prefix.1.txt");
for(my $i = 0;$i <= $spc_num;$i++){
	my $chr_number = keys %{$scaf_order{$i}};
	my $middle = int(($chr_total{$i}+(($chr_number-1)*$gap{$i}))/2);
	my $current = 0;
	my $first_chr = $scaf_order{$i}{0};
	my $first_chr_pos = int($chr_size{$i}{$scaf_order{$i}{0}}/2); 
	foreach my $k (natsort keys %{$scaf_order{$i}}){
		my $cur_add = $current + $chr_size{$i}{$scaf_order{$i}{$k}}+$gap{0};

		if($cur_add < $middle){
			$current += $chr_size{$i}{$scaf_order{$i}{$k}}+$gap{0};
		}else{
			my $start = $middle - $current ;
			my $end = $start;
			print ON "$ID{$i}$first_chr $first_chr_pos $first_chr_pos $spc_name{$i}\n";
			last;
		}
	}
}
close ON;

open(ON3,">$circos_input/$prefix.chr.txt");
for(my $i = 0;$i <= $spc_num;$i++){
	my $chr_number = keys %{$scaf_order{$i}};
	foreach my $k (natsort keys %{$scaf_order{$i}}){
		my $point = int($chr_size{$i}{$scaf_order{$i}{$k}}/2);
		print ON3 "$ID{$i}$scaf_order{$i}{$k} $point $point $scaf_order{$i}{$k}\n";
	}
}
close(ON3);

########################################################
############2. make conf file ################
open(OO,">$circos_input/confs/$prefix.image.conf");
print OO 
"dir   = $outdir
file  = $prefix.svg
svg   = yes
radius   = 400p
auto_alpha_colors = yes
auto_alpha_steps  = 5

<<include etc/background.white.conf>>";
close OO;
my $start_point = 270-(360/(2*($spc_num+1)))+2.16;

open(O4,">$circos_input/confs/$prefix.circos.conf");
print O4 
"
show_links      = yes
show_text       = yes
use_rules       = yes
show_highlights = yes

<<include $prefix.ideogram.conf>>
<<include $prefix.karyotype.and.layout.conf>>
<<include ticks.conf>>
<plots>
<<include $prefix.highlights.conf>>
<<include $prefix.name.conf>>\n";

print O4 
"
</plots>
<links>
show          = conf(show_links)
ribbon        = yes
flat        = yes
radius        = 0.99r-3p
bezier_radius = 0r
color         = black_a5
<link>
file = $prefix.link
</link>
</links>
<image>
<<include $prefix.image.conf>>
angle_offset = $start_point
</image>
<<include etc/colors_fonts_patterns.conf>>
<<include etc/housekeeping.conf>>
data_out_of_range* = trim
";
close O4;

open(O45,">$circos_input/confs/$prefix.name.conf");
print O45
"<plot>
show = conf(show_text)
type = text
file = $prefix.1.txt

color = black
r1 = dims(ideogram,radius_outer) +170p
r0 = dims(ideogram,radius_outer) +40p

label_size = 15p
label_font = bold
rpadding     = 0r
padding      = 0r

show_links     = no
label_parallel = yes
label_rotate = no
</plot>
";
close O45;

open(O5,">$circos_input/confs/$prefix.karyotype.and.layout.conf");
print O5 "karyotype = $circos_input/karyotype/$prefix.karyotype.0.txt";
for(my $i = 1;$i <= $spc_num;$i++){
	print O5 ",$circos_input/karyotype/$prefix.karyotype.$i.txt";
}
print O5 
"\nchromosomes_order_by_karyotype = yes
chromosomes_units              = 1000
chromosomes_display_default    = yes
chromosomes          = -/[XY]/;-/[Un]/;-/[M]/;-/rf/;-/ta/";

for(my $i = 0;$i <= $spc_num;$i++){
	foreach my $ch (natsort keys %{$chr_size{$i}}){
		print O5 ";$ID{$i}$ch";
	}
}
print O5 "\nchromosomes_order = ";
my %chr_sort;
for(my $i = 0;$i <= $spc_num;$i++){
	foreach my $j (natsort keys %{$scaf_order{$i}}){
		$chr_sort{"$ID{$i}$scaf_order{$i}{$j}"} = 0;
	}
}

foreach my $chr_id (natsort keys %chr_sort){
	print O5 "$chr_id,";
}

print O5 "\nchromosomes_scale = ";
my $angle = 1/($spc_num+1);

for(my $i = 0;$i <= $spc_num;$i++){
	foreach my $chr (natsort keys %{$chr_size{$i}}){
		my $size = ($chr_size{$i}{$chr}*$angle/$chr_total{$i});
		print O5 "$ID{$i}$chr:$size","r,";
	}
}
close O5;


open(O6,">$circos_input/confs/$prefix.highlights.conf");
print O6
"<plot>
show = conf(show_highlights)
type = highlight
file = $prefix.highlight
r0   = dims(ideogram,radius_outer) - 20p
r1   = dims(ideogram,radius_outer) 
z=0
stroke_thickness = 0p 
</plot>
";
close O6;

open(O7,">$circos_input/confs/$prefix.ideogram.conf");
my $temp_angle = (1/360);
print O7

"<ideogram>
show = yes
<spacing>

default = 0.003r\n";
for(my $i=0;$i <= $spc_num;$i++){
print O7
"<pairwise \"/$ID{$i}/ /$ID{$i+1}/\">
spacing = 4r
</pairwise>

";
}

print O7
"<pairwise \"/$ID{$spc_num}/ /$ID{0}/\">
spacing = 4r
</pairwise>
";

print O7 
"</spacing>

thickness         = 20p
stroke_thickness = 1
stroke_color     = black_a3
fill           = yes
fill_color     = black

radius         = 0.7r
show_label     = yes
label_font     = default
label_radius   = dims(ideogram,radius_outer) + 16p
label_size     = 13p
label_parallel = yes
label_rotate = no

show_bands            = yes
fill_bands            = yes
band_stroke_thickness = 0
band_stroke_color     = white
band_transparency     = 2

</ideogram>";
close O7;
#########################################################
`$circos_dir/bin/circos -conf $circos_input/confs/$prefix.circos.conf 2> $outdir/circos.log`;
`convert -density 100 $outdir/circos.svg $outdir/circos.pdf`;
`convert -density 100 $outdir/circos.svg $outdir/circos.png`;
`convert -density 100 $outdir/circos.svg $outdir/circos.jpg`;
`chmod -R 777 $outdir/`;
`rm -rf $circos_input`;
