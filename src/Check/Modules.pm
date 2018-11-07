=pod

=head1 NAME

Circos::Modules - module checking for Circos

=head1 SYNOPSIS

This module is not meant to be used directly.

=head1 DESCRIPTION

Circos is an application for the generation of publication-quality,
circularly composited renditions of genomic data and related
annotations.

Circos is particularly suited for visualizing alignments, conservation
and intra and inter-chromosomal relationships. However, Circos can be
used to plot any kind of 2D data in a circular layout - its use is not
limited to genomics. Circos' use of lines to relate position pairs
(ribbons add a thickness parameter to each end) is effective to
display relationships between objects or positions on one or more
scales.

All documentation is in the form of tutorials at L<http://www.circos.ca>.

=cut

# -------------------------------------------------------------------

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw(
module_check
);

our @modules = (
								"Carp qw(carp confess croak)",
								"Clone",
								"Config::General 2.54",
								"Cwd",
								"Data::Dumper",
								"Digest::MD5 qw(md5_hex)",
								"File::Basename",
								"File::Spec::Functions",
								"File::Temp qw(tempdir)",
								"FindBin",
								"Font::TTF::Font",
								"GD",
								"GD::Polyline",
								"Getopt::Long",
								"IO::File",
								"List::MoreUtils qw(uniq)",
								"List::Util qw(max min)",
								"Math::Bezier",
								"Math::BigFloat",
								"Math::Round qw(round nearest)",
								"Math::VecStat qw(sum average)",
								"Memoize",
								"POSIX qw(atan)",
								"Params::Validate qw(:all)",
								"Pod::Usage",
								"Readonly",
								"Regexp::Common qw(number)",
								"Set::IntSpan 1.16 qw(map_set)",
								"Statistics::Basic qw(average stddev)",
								"Storable",
								"SVG",
								"Sys::Hostname",
								"Text::Balanced",
								"Text::Format",
								"Time::HiRes qw(gettimeofday tv_interval)",
								"Sort::Key::Natural qw(natsort)",#additional modules
								"JSON",
								"Data::PowerSet",
								"Parallel::ForkManager",
#Add perl library what we need
							 );

# Checks whether required modules (names found in @modules) are installed.
#
# Returns 0 if some modules are missing or report (using -modules) was generated
# Returns 1 if all modules are installed 

sub check_modules {
	my @missing;
	for my $m (@modules) {
		my ($root) = split(" ",$m);
		if(eval "use $m; 1") {
	    #
		} else {
	    push @missing, [$m,$@];
		}
	}
	for my $m (sort @modules) {
	    my $is_missing = grep($_->[0] eq $m, @missing) || 0;
	    $m =~ s/ .*//;
	    my $version = "";
	    if(! $is_missing) {
				eval { my $ver_str = $m . "::VERSION" ; $version =  eval "\$$ver_str" };
				$version ||= "?";
	    }
	    printf("%s %10s %s\n", $is_missing ? "missing" : "ok",$version,$m);
	}
	return 0;
}
