package Sort::Key;

our $VERSION = '1.33';

use 5.006;

use strict;
use warnings;
use Carp;

use Sort::Key::Types;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( nsort nsort_inplace
		     isort isort_inplace
		     usort usort_inplace
		     rsort rsort_inplace
		     rnsort rnsort_inplace
		     risort risort_inplace
		     rusort rusort_inplace

		     keysort keysort_inplace
		     rkeysort rkeysort_inplace
		     nkeysort nkeysort_inplace
		     rnkeysort rnkeysort_inplace
		     ikeysort ikeysort_inplace
		     rikeysort rikeysort_inplace
		     ukeysort ukeysort_inplace
		     rukeysort rukeysort_inplace

		     multikeysorter multikeysorter_inplace);

require XSLoader;
XSLoader::load('Sort::Key', $VERSION);

sub multikeysorter {
    if (ref $_[0] eq 'CODE') {
	my $keygen = shift;
	@_ or croak "too few keys";
        my $ptypes = Sort::Key::Types::combine_types(@_);
	my $sub = Sort::Key::Types::combine_sub($keygen, undef, @_);
	return _multikeysorter($ptypes, $sub, undef);
    }
    else {
	@_ or croak "too few keys";
        my $ptypes = Sort::Key::Types::combine_types(@_);
	my $sub = Sort::Key::Types::combine_sub('@_', undef, @_);
	return _multikeysorter($ptypes, undef, $sub)
    }
}

sub multikeysorter_inplace {
    if (ref $_[0] eq 'CODE') {
	my $keygen = shift;
	@_ or croak "too few keys";
        my $ptypes = Sort::Key::Types::combine_types(@_);
	my $sub = Sort::Key::Types::combine_sub($keygen, undef, @_);
	return _multikeysorter_inplace($ptypes, $sub, undef);
    }
    else {
	@_ or croak "too few keys";
        my $ptypes = Sort::Key::Types::combine_types(@_);
	my $sub = Sort::Key::Types::combine_sub('@_', undef, @_);
	return _multikeysorter_inplace($ptypes, undef, $sub);
    }
}

sub register_type {
    warn "Warning, Sort::Key API changed: register_type function has been moved to module Sort::Key::Types";
    goto &Sort::Key::Types::register_type;
}


1;

__END__

=head1 NAME

Sort::Key - the fastest way to sort anything in Perl

=head1 SYNOPSIS

  use Sort::Key qw(keysort nkeysort ikeysort);

  @by_name = keysort { "$_->{surname} $_->{name}" } @people;

  # sorting by a numeric key:
  @by_age = nkeysort { $_->{age} } @people;

  # sorting by a numeric integer key:
  @by_sons = ikeysort { $_->{sons} } @people;

=head1 DESCRIPTION

Sort::Key provides a set of functions to sort lists of values by some
calculated key value.

It is faster (usually B<much faster>) and uses less memory than other
alternatives implemented around perl sort function (ST, GRT, etc.).

Multi-key sorting functionality is also provided via the companion
modules L<Sort::Key::Multi>, L<Sort::Key::Maker> and
L<Sort::Key::Register>.

=head2 FUNCTIONS

This module provides a large number of sorting subroutines but
they are all variations off the C<keysort> one:

  @sorted = keysort { CALC_KEY($_) } @data

that is conceptually equivalent to

  @sorted = sort { CALC_KEY($a) cmp CALC_KEY($b) } @data

and where C<CALC_KEY($_)> can be any expression to extract the key
value from C<$_> (not only a subroutine call).

For instance, some variations are C<nkeysort> that performs a numeric
comparison, C<rkeysort> that orders the data in descending order,
C<ikeysort> and C<ukeysort> that are optimized versions of C<nkeysort>
that can be used when the keys are integers or unsigned integers
respectively, etc.

Also, inplace versions of the sorters are provided. For instance

  keysort_inplace { CALC_KEY($_) } @data

that is equivalent to

  @data = keysort { CALC_KEY($_) } @data

but being (a bit) faster and using less memory.

The full list of subroutines that can be imported from this module
follows:

=over 4

=item keysort { CALC_KEY } @array

returns the elements on C<@array> sorted by the key calculated
applying C<{ CALC_KEY }> to them.

Inside C<{ CALC_KEY }>, the object is available as C<$_>.

For example:

  @a=({name=>john, surname=>smith}, {name=>paul, surname=>belvedere});
  @by_name=keysort {$_->{name}} @a;

This function honours the C<use locale> pragma.

=item nkeysort { CALC_KEY } @array

similar to C<keysort> but compares the keys numerically instead of as
strings.

This function honours the C<use integer> pragma, i.e.:

  use integer;
  my @s=(2.4, 2.0, 1.6, 1.2, 0.8);
  my @ns = nkeysort { $_ } @s;
  print "@ns\n"

prints

  0.8 1.6 1.2 2.4 2

=item rnkeysort { CALC_KEY } @array

works as C<nkeysort>, comparing keys in reverse (or descending) numerical order.

=item ikeysort { CALC_KEY } @array

works as C<keysort> but compares the keys as integers (32 bits or more,
no checking is performed for overflows).

=item rikeysort { CALC_KEY } @array

works as C<ikeysort>, but in reverse (or descending) order.

=item ukeysort { CALC_KEY } @array

works as C<keysort> but compares the keys as unsigned integers (32 bits
or more).

For instance, it can be used to efficiently sort IP4 addresses:

  my @data = qw(1.2.3.4 4.3.2.1 11.1.111.1 222.12.1.34
                0.0.0.0 255.255.255.0) 127.0.0.1);

  my @sorted = ukeysort {
                   my @a = split /\./;
                   (((($a[0] << 8) + $a[1] << 8) + $a[2] << 8) + $a[3])
               } @data;

=item rukeysort { CALC_KEY } @array

works as C<ukeysort>, but in reverse (or descending) order.

=item keysort_inplace { CALC_KEY } @array

=item nkeysort_inplace { CALC_KEY } @array

=item ikeysort_inplace { CALC_KEY } @array

=item ukeysort_inplace { CALC_KEY } @array

=item rkeysort_inplace { CALC_KEY } @array

=item rnkeysort_inplace { CALC_KEY } @array

=item rikeysort_inplace { CALC_KEY } @array

=item rukeysort_inplace { CALC_KEY } @array

work as the corresponding C<keysort> functions but sorting the array
inplace.

=item rsort @array

=item nsort @array

=item rnsort @array

=item isort @array

=item risort @array

=item usort @array

=item rusort @array

=item rsort_inplace @array

=item nsort_inplace @array

=item rnsort_inplace @array

=item isort_inplace @array

=item risort_inplace @array

=item usort_inplace @array

=item rusort_inplace @array

are simplified versions of its C<keysort> cousins. They use the own
values as the sorting keys.

For instance those constructions are equivalent:

  @sorted = nsort @foo;

  @sorted = nkeysort { $_ } @foo;

  @sorted = sort { $a <=> $b } @foo;


=item multikeysorter(@types)

=item multikeysorter_inplace(@types)

=item multikeysorter(\&genkeys, @types)

=item multikeysorter_inplace(\&genkeys, @types)

are the low level interface to the multi-key sorting functionality
(normally, you should use L<Sort::Key::Maker> and
L<Sort::Key::Register> or L<Sort::Key::Multi> instead).

They get a list of keys descriptions and return a reference to a
multi-key sorting subroutine.

Types accepted by default are:

  string, str, locale, loc, integer, int,
  unsigned_integer, uint, number, num

and support for additional types can be added via the L<register_type>
subroutine available from L<Sort::Key::Types> or the more
friendly interface available from L<Sort::Key::Register>.

Types can be preceded by a minus sign to indicate descending order.

If the first argument is a reference to a subroutine it is used as the
multi-key extraction function. If not, the generated sorters
expect one as their first argument.

Example:

  my $sorter1 = multikeysorter(sub {length $_, $_}, qw(int str));
  my @sorted1 = &$sorter1(qw(foo fo o of oof));

  my $sorter2 = multikeysorter(qw(int str));
  my @sorted2 = &$sorter2(sub {length $_, $_}, qw(foo fo o of oof));


=back


=head1 SEE ALSO

perl L<sort> function, L<integer>, L<locale>.

Companion modules L<Sort::Key::Multi>, L<Sort::Key::Register>,
L<Sort::Key::Maker> and L<Sort::Key::Natural>.

L<Sort::Key::IPv4>, L<Sort::Key::DateTime> and L<Sort::Key::OID>
modules add support for additional datatypes to Sort::Key.

L<Sort::Key::External> allows to sort huge lists that do not fit in
the available memory.

Other interesting Perl sorting modules are L<Sort::Maker>,
L<Sort::Naturally> and L<Sort::External>.

=head1 SUPPORT

To report bugs, send me and email or use the CPAN bug tracking system
at L<http://rt.cpan.org>.

=head2 Commercial support

Commercial support, professional services and custom software
development around this module are available through my current
company. Drop me an email with a rough description of your
requirements and we will get back to you ASAP.

=head2 My wishlist

If you like this module and you're feeling generous, take a look at my
Amazon Wish List: L<http://amzn.com/w/1WU1P6IR5QZ42>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2007, 2012, 2014 by Salvador FandiE<ntilde>o,
E<lt>sfandino@yahoo.comE<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
