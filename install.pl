#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use File::Basename;
use Cwd 'abs_path';
use Getopt::Long qw(:config no_ignore_case);

my $func = shift;
my $root_path = $FindBin::RealBin;
my $webroot_path = "/var/www/html";
my $data_dir = "$root_path/data";
my $config_F = "";
my $help;
my $manager_name = "mySyntenyPortal";
my $core = 10;

GetOptions (
		"web_root|w=s" => \$webroot_path,
		"manager_name|m=s" => \$manager_name,
		"help|h" => \$help,
);

if(!$func || $help){
	&print_help(); exit(1);
} elsif($func eq "build"){
	##### Compiling third party tools #####
	print STDERR "\nCompiling third party tools...\n";
	chdir("$root_path/src");
	my $install_flag = `./install.sh`;
	if($install_flag =~ /ERROR!/){
		print STDERR "$install_flag\n";
		exit(1);
	} else {
		print STDERR "Success!!\n\n";
	}
	##### Making a symbolic link in the publish template #####
	`ln -s $root_path/src/third_party/circos $root_path/scripts/publish_template/script/circos`;
	`ln -s $root_path/htdocs/img $root_path/scripts/publish_template/htdocs/img`;

	##### Making an index html file #####
	open(W,">$root_path/index.html");
	print W "<html>\n<meta http-equiv=\"refresh\" content=\"0; URL='./htdocs/main.php'\"/>\n</html>\n";
	close(W);
	`mkdir -m777 -p $root_path/publish`;
} elsif($func eq "install"){
	if(-l "$webroot_path/$manager_name"){
		print STDERR "\n'$webroot_path/$manager_name' is already existing!\n\n";
		exit(1);
	}
	##### Building path information to htdocs/path_info.txt #####
	print STDERR "\nBuilding path information... ";
	open(W,">$root_path/htdocs/path_info.txt");
	print W ">mySyntenyPortal webroot\nwebroot_path=$webroot_path/$manager_name\n\n";
	print W ">mySyntenyPortal root\nmySyntenyPortal_root_path=$root_path\n";
	close(W);
	`touch $root_path/htdocs/.path_tmp`;
	`chmod 777 $root_path/htdocs/.path_tmp`;
	`chmod 777 $root_path/htdocs/path_info.txt`;
	print STDERR "Done!\n";
	`ln -s $root_path $webroot_path/$manager_name`;
	print STDERR "\nYou can access mySyntenyPortal by http://your.host/$manager_name\n\n";
} elsif ($func eq "clean") {
	print STDERR "\nAre you sure to clean mySyntenyPortal and Website manager ($manager_name)?\n";
	print STDERR "YES or NO : ";
	my $confirm = <STDIN>;
	if($confirm !~ /^Y|YES|y|yes$/){
		print STDERR "\n";
		exit(1);
	}
	`rm -f $webroot_path/$manager_name`;
	`rm -rf $root_path/data/Sample_website $root_path/publish`;
	`rm -f $root_path/index.html $root_path/scripts/publish_template/script/circos $root_path/scripts/publish_template/htdocs/img $root_path/htdocs/path_info.txt $root_path/htdocs/.path_tmp`;
	`make clean -C $root_path/src/third_party/makeBlocks`;
	`make clean -C $root_path/src/third_party/bedtools`;
	`make clean -C $root_path/src/third_party/lastz`;
} else {
	&print_help();
}

sub print_help{
	print STDERR "
Usage:  ./install.pl [build|install|clean] <parameters>
  
  ** It requires a 'sudo' privilege for the 'install' command. **

Simple examples:
    ./install.pl build
    ./install.pl install
    ./install.pl clean

Commands:
    build    =>  complile third party tools and set path information
    install  =>  make a symbolic link in the web root directory
    clean    =>  clean up third party tools and remove the symbolic link in the web root directory

Parameters:
  [ install ]
    -webroot_path|w => Apache web root path (default: /var/www/html)
    -manager_name|m => Website manager name (default: mySyntenyPortal)
  
  [ clean ]
    -manager_name|m => Website manager name (default: mySyntenyPortal)

";
}
