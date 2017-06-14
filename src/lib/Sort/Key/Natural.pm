package Sort::Key::Natural;

our $VERSION = '0.04';

use strict;
use warnings;

require Exporter;

our @ISA = qw( Exporter );
our @EXPORT_OK = qw( natkeysort
		     natkeysort_inplace
		     rnatkeysort
		     rnatkeysort_inplace
		     mkkey_natural
		     natsort
		     rnatsort
		     natsort_inplace
		     rnatsort_inplace 

                     natwfkeysort
		     natwfkeysort_inplace
		     rnatwfkeysort
		     rnatwfkeysort_inplace
		     mkkey_natural_with_floats
		     natwfsort
		     rnatwfsort
		     natwfsort_inplace
		     rnatwfsort_inplace );


require locale;

sub mkkey_natural {
    my $nat = @_ ? shift : $_;
    my @parts = do {
        if ((caller 0)[8] & $locale::hint_bits) {
            use locale;
            $nat =~ /\d+|\p{IsAlpha}+/g;
        }
        else {
            $nat =~ /\d+|\p{IsAlpha}+/g;
        }
    };
    for (@parts) {
	if (/^\d/) {
	    s/^0+//;
	    my $len = length;
	    my $nines = int ($len / 9);
	    my $rest = $len - 9 * $nines;
	    $_ = ('9' x $nines) . $rest . $_;
	}
    }
    return join("\0", @parts);
}

use Sort::Key::Register natural => \&mkkey_natural, 'string';
use Sort::Key::Register nat => \&mkkey_natural, 'string';

use Sort::Key::Maker natkeysort => 'nat';
use Sort::Key::Maker rnatkeysort => '-nat';
use Sort::Key::Maker natsort => \&mkkey_natural, 'str';
use Sort::Key::Maker rnatsort => \&mkkey_natural, '-str';

sub mkkey_natural_with_floats {
    my $nat = @_ ? shift : $_;
    my @parts = do {
        if ((caller 0)[8] & $locale::hint_bits) {
            use locale;
            $nat =~ /[+\-]?\d+(?:\.\d*)?|\p{IsAlpha}+/g;
        }
        else {
            $nat =~ /[+\-]?\d+(?:\.\d*)?|\p{IsAlpha}+/g;
        }
    };
    for (@parts) {
        if (my ($sign, $number, $dec) = /^([+-]?)(\d+)(?:\.(\d*))?$/) {
            $number =~ s/^0+//;
            $dec = '' unless defined $dec;
            $dec =~ s/0+$//;
	    my $len = length $number;
	    my $nines = int ($len / 9);
	    my $rest = $len - 9 * $nines;
            $_ = ('9' x $nines) . $rest . $number . $dec;
            if ($sign eq '-' and $_ ne '0') {
                tr/0123456789/9876543210/;
                $_ = "-$_";
            }
	}
    }
    return join("\0", @parts);
}

use Sort::Key::Register natural_with_floats => \&mkkey_natural_with_floats, 'string';
use Sort::Key::Register natwf => \&mkkey_natural_with_floats, 'string';

use Sort::Key::Maker natwfkeysort => 'natwf';
use Sort::Key::Maker rnatwfkeysort => '-natwf';
use Sort::Key::Maker natwfsort => \&mkkey_natural_with_floats, 'str';
use Sort::Key::Maker rnatwfsort => \&mkkey_natural_with_floats, '-str';


1;

=head1 NAME

Sort::Key::Natural - fast natural sorting

=head1 SYNOPSIS

    use Sort::Key::Natural qw(natsort);

    my @data = qw(foo1 foo23 foo6 bar12 bar1
		  foo bar2 bar-45 foomatic b-a-r-45);

    my @sorted = natsort @data;

    print "@sorted\n";
    # prints:
    #   b-a-r-45 bar1 bar2 bar12 bar-45 foo foo1 foo6 foo23 foomatic

    use Sort::Key::Natural qw(natkeysort);

    my @objects = (...);
    my @sorted = natkeysort { $_->get_id } @objects;


=head1 DESCRIPTION

This module extends the L<Sort::Key> family of modules to support
natural sorting.

Under natural sorting, strings are split at word and number
boundaries, and the resulting substrings are compared as follows:

=over 4

=item *

numeric substrings are compared numerically

=item *

alphabetic substrings are compared lexically

=item *

numeric substrings come always before alphabetic substrings

=back

Spaces, symbols and non-printable characters are only considered for
splitting the string into its parts but not for sorting. For instance
C<foo-bar-42> is broken in three substrings C<foo>, C<bar> and C<42>
and after that the dashes are ignored.

Note, that the sorting is case sensitive. To do a case insensitive
sort you have to convert the keys explicitly:

  my @sorted = natkeysort { lc $_ } @data

Also, once this module is loaded, the new type C<natural> (or C<nat>) will
be available from L<Sort::Key::Maker>. For instance:

  use Sort::Key::Natural;
  use Sort::Key::Maker i_rnat_keysort => qw(integer -natural);

creates a multi-key sorter C<i_rnat_keysort> accepting two keys, the
first to be compared as an integer and the second in natural
descending order.

There is also an alternative set of natural sorting functions that
recognize floating point numbers. They use the key type C<natwf>
(abbreviation of C<natural_with_floats>).

=head2 FUNCTIONS

the functions that can be imported from this module are:

=over 4

=item natsort @data

returns the elements of C<@data> sorted in natural order.

=item rnatsort @data

returns the elements of C<@data> sorted in natural descending order.

=item natkeysort { CALC_KEY($_) } @data

returns the elements on C<@array> naturally sorted by the keys
resulting from applying them C<CALC_KEY>.

=item rnatkeysort { CALC_KEY($_) } @data

is similar to C<natkeysort> but sorts the elements in descending
order.

=item natsort_inplace @data

=item rnatsort_inplace @data

=item natkeysort_inplace { CALC_KEY($_) } @data

=item rnatkeysort_inplace { CALC_KEY($_) } @data

these functions are similar respectively to C<natsort>, C<rnatsort>,
C<natsortkey> and C<rnatsortkey>, but they sort the array C<@data> in
place.

=item $key = mkkey_natural $string

given C<$string>, returns a key that can be compared lexicographically
to another key obtained in the same manner, results in the same order
as comparing the former strings as in the natural order.

If the argument C<$key> is not provided it defaults to C<$_>.

=item natwfsort @data

=item rnatwfsort @data

=item natwfkeysort { CALC_KEY($_) } @data

=item rnatwfkeysort { CALC_KEY($_) } @data

=item natwfsort_inplace @data

=item rnatwfsort_inplace @data

=item natwfkeysort_inplace { CALC_KEY($_) } @data

=item rnatwfkeysort_inplace { CALC_KEY($_) } @data

=item mkkey_natural_with_floats $key

this ugly named set of functions perform in the same way as its
s/natwf/nat/ counterpart with the difference that they honor floating
point numbers embedded inside the strings.

In this context a floating point number is a string matching the
regular expression C</[+\-]?\d+(\.\d*)?/>. Note that numbers with an
exponent part (i.e. C<1.12E-12>) are not recognized as such.

Note also that numbers without an integer part (i.e. C<.2> or C<-.12>)
are not supported either.

=back

=head1 SEE ALSO

L<Sort::Key>, L<Sort::Key::Maker>.

Other module providing similar functionality is L<Sort::Naturally>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2012, 2014 by Salvador FandiE<ntilde>o,
E<lt>sfandino@yahoo.comE<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
