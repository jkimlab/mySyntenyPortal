package Sort::Key::Multi;

our $VERSION = '1.30';

use warnings;
use strict;

use Sort::Key qw(multikeysorter multikeysorter_inplace);
use Sort::Key::Types;

use Carp;
our @CARP_NOT = qw(Sort::Key);

my %sub;
my %type = qw( i integer
	       u unsigned_integer
	       n number
	       s string
	       l locale);

my $one_char_types = join('', keys %Sort::Key::Types::mktypes);

sub import {
    shift;
    for my $name (@_) {
	my $sub = $sub{$name};
	unless (defined $sub) {
	    my ($types, $inplace) = $name =~ /^((?:r?[$one_char_types]\d*_*)+)keysort((?:_?inplace)?)$/o
		or croak "invalid name for multikey sorter '$name'";
	    my @types;
	    while ($types =~ /(r?)(.)(\d*)_*/g) {
		my ($r, $t, $n) = ($1, $2, $3);
		push @types, ( ($r ? '-' : '') . $type{$t} ) x ($n || 1);
	    }
	    # print STDERR "$types => @types\n";
	    if ($inplace) {
		$sub = multikeysorter_inplace(@types);
	    }
	    else {
		$sub = multikeysorter(@types);
	    }
	}
	my $caller = caller;
	no strict 'refs';
	*{$caller."::".$name} = $sub;
    }
}

1;

=head1 NAME

Sort::Key::Multi - simple multi-key sorts

=head1 SYNOPSIS

    use Sort::Key::Multi qw(sikeysort);
    my @data = qw(foo0 foo1 bar34 bar0 bar34 bar33 doz4)
    my @sisorted = sikeysort { /(\w+)(\d+)/} @data;

=head1 DESCRIPTION

Sort::Key::Multi creates multi-key sorting subroutines and exports them
to the caller package.

The names of the sorters are of the form C<xxxkeysort> or
C<xxxkeysort_inplace>, where C<xxx> determines the number and types of
the keys as follows:

=over 4

+ C<i> indicates an integer key, C<u> indicates an unsigned integer
key, C<n> indicates a numeric key, C<s> indicates a string key and
C<l> indicates a string key that obeys locale order configuration.

+ Type characters can be prefixed by C<r> to indicate reverse order.

+ A number following a type character indicates that the key type has
to be repeated as many times (for instance C<i3> is equivalent to
C<iii> and C<rs2> is equivalent to C<rsrs>).

+ Underscores (C<_>) can be freely used between type indicators.

=back

For instance:

   use Key::Sort::Multi qw(iirskeysort
                           i2rskeysort
                           i_i_rs__keysort
                           i2rs_keysort);

exports to the caller package fourth identical sorting functions that
take two integer keys that are sorted in ascending order and one
string key that is sorted in descending order.

The generated sorters take as first argument a subroutine that is used
to extract the keys from the values which are passed inside C<$_>, for
example:

  my @data = qw(1.3.foo 1.3.bar 2.3.bar 1.4.bar 1.7.foo);
  my @s = i2rs_keysort { split /\./, $_ } @data;

=head1 SEE ALSO

For a more general multi-key sorter generator see L<Sort::Key::Maker>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2014 by Salvador FandiE<ntilde>o
E<lt>sfandino@yahoo.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
