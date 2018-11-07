#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Getopt::Long qw(:config no_ignore_case);
use Sort::Key::Natural 'natsort';
use Data::PowerSet 'powerset';
use FindBin '$Bin';
use File::Basename;
use Cwd 'abs_path';

my $config_F = "";
my $core = 1;
my $help;

GetOptions (
		"config|conf=s" => \$config_F,
		"core|p=i" => \$core,
		"help|h" => \$help,
);

if($help || $config_F eq ""){
	print STDERR "
	build_mySyntenyPortal.pl -conf [configuration file] -p [core number]
		
		
";
	exit(1);
}

my $project_name = "";
my $project_desc = "";
my @arr_tar_name = ();
my %hs_tar_fa = ();
my %hs_divtime = ();
my @arr_resolution = ();
my %hs_tar_syn = ();
my %hs_tar_sizes = ();
my %hs_tar_ann = ();
my %hs_cytoband = ();
my $circos_order = 0;
my %hs_circos_info = ();
my %hs_circos_spc = ();
my $initial_ref_name = "";
my $initial_tar_name = "";
my $email = "";

$config_F = abs_path($config_F);
my $config_path = dirname($config_F);
chdir($config_path);

##### Reading a configuration file #####
my $flag = "";
my $assembly_flag = 0;
my $synteny_flag = 0;
print STDERR "##### Read a configuration file #####\n - $config_F\n";
open(F,"$config_F");
while(<F>){
	chomp;
	if($_ eq "" || $_ =~ /^#/){next;}
	if($_ =~ /^>/){
		if($_ eq ">Website_name"){$flag = "projectName";}
		elsif($_ eq ">Assemblies"){$flag = "assembly"; $assembly_flag = 1;}
		elsif($_ eq ">Divtimes"){$flag = "divtime";}
		elsif($_ eq ">Resolutions"){$flag = "resolution";} 
		elsif($_ eq ">Synteny_blocks"){$flag = "synteny"; $synteny_flag = 1;}
		elsif($_ eq ">Genome_size"){$flag = "sizes";}
		elsif($_ eq ">Annotation"){$flag = "annotation";}
		elsif($_ eq ">Cytoband"){$flag = "cytoband";}
		elsif($_ eq ">Email"){$flag = "email";}
		elsif($_  =~ /(circos\d+)/){$flag = $1; $circos_order = 0;}
		else {
			print STDERR "Wrong configuration file\n";
			print STDERR "$_\n";
			exit(1);
		}
		next;
	}

	if($flag eq "projectName"){
		$project_name = $_;
		$project_name =~ s/\s+//g;
	} elsif($flag eq "projectDesc"){
		$project_desc .= "$_<br>";
	} elsif($flag eq "assembly"){
		my @arr = split(/\s+/);
		push(@arr_tar_name,$arr[0]);
		$hs_tar_fa{$arr[0]} = abs_path($arr[1]);
	} elsif($flag eq "divtime"){
		my @arr = split(/\s+/);
		my @arr2 = split(/,/,$arr[0]);
		$hs_divtime{$arr2[0]}{$arr2[1]} = $arr[1];
		$hs_divtime{$arr2[1]}{$arr2[0]} = $arr[1];
	} elsif($flag eq "resolution"){
		my @arr = split(/,/);
		push(@arr_resolution,@arr);
	} elsif($flag eq "synteny"){
		my @arr = split(/\s+/);
		my @arr_spc = split(/,/,$arr[0]);
		$hs_tar_syn{$arr_spc[0]}{$arr_spc[1]} = abs_path($arr[1]);
	} elsif($flag eq "sizes"){
		my @arr = split(/\s+/);
		$hs_tar_sizes{$arr[0]} = abs_path($arr[1]);
	} elsif($flag eq "annotation"){
		my @arr = split(/\s+/);
		$hs_tar_ann{$arr[0]} = abs_path($arr[1]);
	} elsif($flag eq "cytoband"){
		my @arr = split(/\s+/);
		$hs_cytoband{$arr[0]} = abs_path($arr[1]);
	} elsif($flag eq "email"){
		$email = $_;
	} elsif($flag =~ /circos/){
		my @arr = split(/\s*:\s*/);
		if($arr[0] eq "resolution"){
			$hs_circos_info{$flag}{'res'} = $arr[1];
		} else {
			$hs_circos_info{$flag}{$circos_order} = "$arr[0]\t$arr[1]";
			$hs_circos_spc{$flag}{$arr[0]} = 0;
			$circos_order++;
		}
	}
}
close(F);

if($assembly_flag == $synteny_flag){
	print STDERR "Error 1\n";
	exit(1);
} elsif($assembly_flag == 1){
	print STDERR " => Input data type: Assembly\n";
} elsif($synteny_flag == 1){
	print STDERR " => Input data type: Synteny blocks\n";
}

##### PATH #####
my $path_info_F = "$Bin/../htdocs/path_info.txt";
$path_info_F = abs_path($path_info_F);
my $data_dir = "$Bin/../data";
$data_dir = abs_path($data_dir);
my $out_dir = "$data_dir/$project_name";
my $chainNet_path = "$out_dir/chainNet";
my $size_path = "$out_dir/sizes";
my $synteny_path = "$out_dir/synteny";
my $browser_path = "$out_dir/browser";
my $circos_path = "$out_dir/circos";
my $circos_src = "$Bin/../src/third_party/circos";
my $kent_src = "$Bin/../src/third_party/kent";

my %tar_info = ();
`mkdir -p $out_dir`;
if($assembly_flag == 1){
##### Making alignments #####
print STDERR "\n##### Alignment #####\n";
my $chainSwap_cmd = "$kent_src/chainSwap";
@arr_resolution = natsort @arr_resolution;
`mkdir -p $chainNet_path $size_path`;
my %hs_chainNet_list;
if(-f "$chainNet_path/chainNet_list"){
	open(F,"$chainNet_path/chainNet_list");
	while(<F>){
		chomp;
		my @arr = split(/\s+/);
		$hs_chainNet_list{$arr[0]}{$arr[1]} = 1;
	}
	close(F);
}
for(my $i = 0;$i < $#arr_tar_name;$i++){
	for(my $j = $i+1;$j <= $#arr_tar_name;$j++){
		my $ref_name = $arr_tar_name[$i];
		my $tar_name = $arr_tar_name[$j];
		my $ref_fa = $hs_tar_fa{$ref_name};
		my $tar_fa = $hs_tar_fa{$tar_name};
		my $min_resolution = $arr_resolution[0];
		my $divtime = $hs_divtime{$ref_name}{$tar_name};
		print STDERR " - $ref_name-$tar_name $divtime\n";
		if(!exists $hs_chainNet_list{"$ref_name,$tar_name"}{$divtime}){
			`$Bin/alignment.pl -p $core -d $divtime -m $min_resolution -r $ref_fa -t $tar_fa -o $chainNet_path 2>> $chainNet_path/log.txt`;
			$hs_chainNet_list{"$ref_name,$tar_name"}{$divtime} = 1;
		}
		
		if(!-f "$size_path/$ref_name.sizes"){
			my $ref_fa_base = basename($ref_fa,".fa");
			`cp $chainNet_path/building/$ref_name.$tar_name/ref/$ref_fa_base.sizes $size_path/$ref_name.sizes`;
			`$Bin/natsort.pl $size_path/$ref_name.sizes`;
		}
	
		if(!-f "$size_path/$tar_name.sizes"){
			my $tar_fa_base = basename($tar_fa,".fa");
			`cp $chainNet_path/building/$ref_name.$tar_name/tar/$tar_fa_base.sizes $size_path/$tar_name.sizes`;
			`$Bin/natsort.pl $size_path/$tar_name.sizes`;
		}

		`rm -rf $chainNet_path/building`;
	}
}
open(W,">$chainNet_path/chainNet_list");
foreach my $assemblies (natsort keys %hs_chainNet_list){
	foreach my $divtime (natsort keys %{$hs_chainNet_list{$assemblies}}){
		print W "$assemblies\t$divtime\n";
	}
}
close(W);

##### Building synteny blocks #####
print STDERR "\n##### Building synteny blocks #####\n";
`mkdir -p $synteny_path`;
my %hs_synteny_list;
if(-f "$synteny_path/synteny_list"){
	open(F,"$synteny_path/synteny_list");
	while(<F>){
		chomp;
		my @arr = split(/\s+/);
		$hs_synteny_list{$arr[0]}{$arr[1]} = 1;
	}
	close(F);
}

foreach my $ref_name (@arr_tar_name){
	foreach my $tar_name (@arr_tar_name){
		if($ref_name eq $tar_name){next;}
		foreach my $resolution (@arr_resolution){
			my $synteny_out = "$synteny_path/$ref_name/$tar_name/$resolution";
			print STDERR " - $ref_name-$tar_name $resolution\n";
			`mkdir -p $synteny_out`;
			if(!exists $hs_synteny_list{"$ref_name,$tar_name"}{$resolution}){
				`$Bin/build_synteny.pl -ch $chainNet_path -r $ref_name -t $tar_name -m $resolution -o $synteny_out`;
				$hs_synteny_list{"$ref_name,$tar_name"}{$resolution} = 1;
			}
		}
	}
}
open(W,">$synteny_path/synteny_list");
foreach my $assemblies (natsort keys %hs_synteny_list){
	foreach my $resolution (natsort keys %{$hs_synteny_list{$assemblies}}){
		print W "$assemblies\t$resolution\n";
	}
}
close(W);
} ## With assembly END

##### Making linear plot inputs #####
print STDERR "\n##### Making linear plot inputs #####\n";
`mkdir -p $browser_path`;
if(!-f "$browser_path/colors.mySyntenyPortal.conf"){`cp $circos_src/etc/colors.mySyntenyPortal.conf $browser_path`;}
if($assembly_flag == 1){
foreach my $ref_name (@arr_tar_name){
	foreach my $tar_name (@arr_tar_name){
		$hs_tar_syn{$ref_name}{$tar_name} = 1;
		if($ref_name eq $tar_name){next;}
		foreach my $resolution (@arr_resolution){
			my $synteny_F = "$synteny_path/$ref_name/$tar_name/$resolution/synteny_blocks.txt";
			print STDERR " - $ref_name-$tar_name $resolution";
			if(-f $synteny_F){
				if(-f "$browser_path/$ref_name.$tar_name.$resolution.linear"){
					print STDERR "  => Already exists!\n";
				} else {
					`$Bin/make_linear_plot.pl -s $synteny_F -r $ref_name -t $tar_name -m $resolution -z $size_path -o $browser_path`;
					print STDERR "\n";
				}
			} else {
				print STDERR "  => No synteny blocks!\n";
			}
		}
	}
}
} elsif($synteny_flag == 1){
`mkdir -p $synteny_path $size_path`;
foreach my $ref_name (keys %hs_tar_syn){
	if($initial_ref_name eq ""){$initial_ref_name = $ref_name;}
	foreach my $tar_name (keys %{$hs_tar_syn{$ref_name}}){
		if($initial_tar_name eq ""){$initial_tar_name = $tar_name;}
		if(!-f "$synteny_path/$ref_name.$tar_name.synteny"){
			`cp $hs_tar_syn{$ref_name}{$tar_name} $synteny_path/$ref_name.$tar_name.synteny`;
		}
		$hs_tar_syn{$ref_name}{$tar_name} = "$synteny_path/$ref_name.$tar_name.synteny";
	}
}

foreach my $spc_name (keys %hs_tar_sizes){
	if(-f "$size_path/$spc_name.sizes"){next;}
	`cp $hs_tar_sizes{$spc_name} $size_path/$spc_name.sizes`;
}

foreach my $ref_name (keys %hs_tar_syn){
	foreach my $tar_name (keys %{$hs_tar_syn{$ref_name}}){
		my $synteny_F = $hs_tar_syn{$ref_name}{$tar_name};
		print STDERR " - $ref_name-$tar_name";
		if(-f "$browser_path/$ref_name.$tar_name.linear"){
			print STDERR "  => Already exists!\n";
		} else {
			`$Bin/make_linear_plot.pl -s $synteny_F -r $ref_name -t $tar_name -z $size_path -o $browser_path`;
			print STDERR "\n";
		}
	}
}
}

##### Making gene track inputs #####
print STDERR "\n##### Making gene track inputs #####\n";
if($assembly_flag == 1){
foreach my $ref_name (@arr_tar_name){
	foreach my $tar_name (@arr_tar_name){
		if($ref_name eq $tar_name){next;}
		foreach my $resolution (@arr_resolution){
			my $synteny_dir = "$synteny_path/$ref_name/$tar_name/$resolution";
			print STDERR " - $ref_name-$tar_name $resolution";
			if(-f "$synteny_dir/synteny_blocks.txt" && exists $hs_tar_ann{$ref_name}){
				if(-f "$browser_path/$ref_name.$tar_name.$resolution.geneTrack"){
					print STDERR "  => Already exsits!\n";
				} else {
					`$Bin/syn2bed.pl -s $synteny_dir/synteny_blocks.txt -o $synteny_dir`;
					`$Bin/make_geneTrack_inputs.pl -gtf $hs_tar_ann{$ref_name} -syn $synteny_dir/$ref_name.bed -r $ref_name -t $tar_name -m $resolution -out $browser_path`;
					`$Bin/gtf_to_json.pl -i $hs_tar_ann{$ref_name} -t $browser_path/tmp -s $size_path/$ref_name.sizes -o $browser_path/$ref_name.id.json`;
					`rm -rf $browser_path/tmp`;
					print STDERR "  => Done!\n";
				}
			} else {
				print STDERR "  => No annotation file!\n";
			}
		}
	}
}
} elsif($synteny_flag == 1){
foreach my $ref_name (keys %hs_tar_syn){
	foreach my $tar_name (keys %{$hs_tar_syn{$ref_name}}){
		print STDERR " - $ref_name-$tar_name";
		if(exists $hs_tar_ann{$ref_name}){
			if(-f "$browser_path/$ref_name.$tar_name.geneTrack"){
				print STDERR "  => Already exists!\n";
			} else {
				`mkdir -p $synteny_path/tmp`;
				`$Bin/syn2bed.pl -s $hs_tar_syn{$ref_name}{$tar_name} -o $synteny_path/tmp`;
				`$Bin/make_geneTrack_inputs.pl -gtf $hs_tar_ann{$ref_name} -syn $synteny_path/tmp/$ref_name.bed -r $ref_name -t $tar_name -out $browser_path`;
				`$Bin/gtf_to_json.pl -i $hs_tar_ann{$ref_name} -t $browser_path/tmp -s $size_path/$ref_name.sizes -o $browser_path/$ref_name.id.json`;
				`rm -rf $synteny_path/tmp`;
				`rm -rf $browser_path/tmp`;
				print STDERR "  => Done!\n";
			}
		} else {
			print STDERR "  => No annotation file!\n";
		}
	}
}
}

##### Drawing pre-configured circos plots #####
print STDERR "\n##### Drawing pre-configured circos plots #####\n";
my $cinfo = "";
my $resolution = 0;
foreach my $flag (natsort keys %hs_circos_info){
	my $circos_out = "$circos_path/$flag";
	`mkdir -p $circos_out`;
	print STDERR " - $flag\n";
	my $circos_info_F = "$circos_out/$flag.info";
	if($assembly_flag == 1){
		$resolution = $hs_circos_info{$flag}{'res'};
		open(W,">$circos_info_F");
		print W "Resolution\t$resolution\n";
		foreach my $order (natsort keys %{$hs_circos_info{$flag}}){
			if($order eq "res"){next;}
			my $circos_info = $hs_circos_info{$flag}{$order};
			my @arr_circos_info = split(/\s+/,$hs_circos_info{$flag}{$order});
			my $circos_info_scaf = $arr_circos_info[1];
			$circos_info_scaf =~ s/chr//g;
			$cinfo .= "|$arr_circos_info[0]|$circos_info_scaf";
			print W "$order\t$circos_info\n";
		}

		foreach my $spc_name (keys %hs_cytoband){
			`mkdir -p $out_dir/cytoband`;
			`cp $hs_cytoband{$spc_name} $out_dir/cytoband/$spc_name.cytoband.txt`;
			$hs_cytoband{$spc_name} = "$out_dir/cytoband/$spc_name.cytoband.txt";
			if(!exists $hs_circos_spc{$flag}{$spc_name}){next;}
			print W "Cytoband\t$spc_name\t$hs_cytoband{$spc_name}\n";
		}
		close(W);
	} elsif($synteny_flag == 1){
		open(W,">$circos_info_F");
		foreach my $order (natsort keys %{$hs_circos_info{$flag}}){
			my $circos_info = $hs_circos_info{$flag}{$order};
			my @arr_circos_info = split(/\s+/,$hs_circos_info{$flag}{$order});
			my $circos_info_scaf = $arr_circos_info[1];
			$circos_info_scaf =~ s/chr//g;
			$cinfo .= "|$arr_circos_info[0]|$circos_info_scaf";
			print W "$order\t$circos_info\n";
		}
		
		foreach my $spc_name (keys %hs_cytoband){
			`mkdir -p $out_dir/cytoband`;
			`cp $hs_cytoband{$spc_name} $out_dir/cytoband/$spc_name.cytoband.txt`;
			$hs_cytoband{$spc_name} = "$out_dir/cytoband/$spc_name.cytoband.txt";
			if(!exists $hs_circos_spc{$flag}{$spc_name}){next;}
			print W "Cytoband\t$spc_name\t$hs_cytoband{$spc_name}\n";
		}
		close(W);
	}
	`$Bin/drawCircos.pl -s $synteny_path -i $circos_info_F -z $size_path -o $circos_out`;
	`$Bin/svg_transform.pl $circos_out/circos.svg $circos_out`;
	open(W,">$circos_path/index");
	print W "1\t$resolution$cinfo\n";
	close(W);
}

##### Adding path info ####
print STDERR "\n##### Adding path info #####\n";
print STDERR " - $project_name\n";
my $project_N = "";
my %hs_project = ();
my %hs_pathSet = ();
$flag = 0;
my @project_arr = ();
open(F,"$path_info_F");
while(<F>){
	chomp;
	if($_ eq ""){next;}
	if($_ =~ /^>/){
		my @arr = split(/>/);
		$project_N = $arr[1];
		$flag++;
		next;
	}

	my @arr = split(/=/);
	if($flag < 3){
		$hs_pathSet{$arr[0]} = $arr[1];
	} else {
		$hs_project{$project_N}{$arr[0]} = $arr[1];
	}
}
close(F);

my $conf_name = basename($config_F);
$hs_project{$project_name}{'Configure_path'} = "[mySyntenyPortal root]/conf/$conf_name";
$hs_project{$project_name}{'Data_path'} = "[mySyntenyPortal root]/data/$project_name";

open(W,">$path_info_F");
print W ">mySyntenyPortal webroot\nwebroot_path=$hs_pathSet{'webroot_path'}\n\n";
print W ">mySyntenyPortal root\nmySyntenyPortal_root_path=$hs_pathSet{'mySyntenyPortal_root_path'}\n\n";
foreach my $project_N (natsort keys %hs_project){
	print W ">$project_N\n";
	foreach my $c (natsort keys %{$hs_project{$project_N}}){
		print W "$c=$hs_project{$project_N}{$c}\n";
	}
	print W "\n";
}
close(W);

my $ref_names = join(',',natsort(keys(%hs_tar_syn)));
my $resolutions = join(',',@arr_resolution);
if($resolutions eq ""){$resolutions = 0;}
open(W,">$out_dir/cur_state");
print W "Website_name\t$project_name\n";
print W "Email\t$email\n";
print W "Ref_names\t$ref_names\n";
foreach my $ref_name (natsort keys %hs_tar_syn){
	my @tmp_tar_arr = ();
	foreach my $tar_name (natsort keys %{$hs_tar_syn{$ref_name}}){
		push(@tmp_tar_arr,$tar_name);
	}
	my $tar_names = join(',',@tmp_tar_arr);
	print W "Tar_names\t$ref_name\t$tar_names\n";
}
print W "Resolutions\t$resolutions\n";
foreach my $spc_name (keys %hs_cytoband){
	print W "Cytoband\t$spc_name\n";
}
if($assembly_flag == 1){
	my $size_head = `head -1 $size_path/$arr_tar_name[0].sizes`;
	my $asmbl_name = (split(/\s+/,$size_head))[0];
	print W "Data_type\tAssembly\n";
	print W "SC\tcircos_num\t1\n";
	print W "SB\tref_name\t$arr_tar_name[0]\n";
	print W "SB\tref_asmbl\t$asmbl_name\n";
	print W "SB\ttar_name\t$arr_tar_name[1]\n";
	print W "SB\tres\t$arr_resolution[0]\n";
} else {
	my $size_head = `head -1 $size_path/$initial_ref_name.sizes`;
	my $asmbl_name = (split(/\s+/,$size_head))[0];
	print W "Data_type\tSynteny\n";
	print W "SC\tcircos_num\t1\n";
	print W "SB\tref_name\t$initial_ref_name\n";
	print W "SB\tref_asmbl\t$asmbl_name\n";
	print W "SB\ttar_name\t$initial_tar_name\n";
	print W "SB\tres\t0\n";
}
close(W);
`cp $out_dir/cur_state $out_dir/.reset_state`;
`touch $out_dir/.state_tmp`;
`chmod -R 777 $out_dir`;

print STDERR "\n#####\nFinished.\n\n";

