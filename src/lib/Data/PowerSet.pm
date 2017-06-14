# Data::PowerSet.pm
#
# Copyright (c) 2005-2008 David Landgren
# All rights reserved

package Data::PowerSet;

use strict;
use Exporter;

use vars qw/$VERSION @ISA @EXPORT_OK/;
$VERSION = '0.05';
@ISA     = ('Exporter');

=head1 NAME

Data::PowerSet - Generate all subsets of a list of elements

=head1 VERSION

This document describes version 0.05 of Data::PowerSet, released
2008-05-13.

=head1 SYNOPSIS

  use Data::PowerSet 'powerset';

  my $powerset = powerset( 3, 1, 4 );
  for my $p (@$powerset) {
    print "@$p\n";
  }

  # prints
  3 1 4
  1 4
  3 4
  4
  3 1
  1
  3

An object-oriented interface is also available;

  my $d = Data::PowerSet->new( 3, 1, 4 );
  while (my $r = $d->next) {
    print "@$r\n";
  }
  # produces the same output as above

=head1 DESCRIPTION

C<Data::PowerSet> takes a list and returns all possible
combinations of the elements appearing in the list without replacement.

=head1 EXPORTABLE FUNCTIONS

=over 8

=item powerset

The C<powerset> function takes an array (or a reference to an array) on
input and returns a reference to an array of arrays containing all the
possible unique combinations of elements.

It is also possible to supply a reference to hash as the first
parameter to tweak the behaviour. See the C<new> method for a
description of what keys can be specified.

  powerset( 2, 5, 10, 17 );

  powerset( {min => 1}, qw(a b c d) );

  powerset( [qw[ bodine mondaugen gadrulfi fleische eigenvalue ]] );

=cut

push @EXPORT_OK, 'powerset';
sub powerset {
    my %args;
    if (ref($_[0]) eq 'HASH') {
        %args = %{shift @_};
    }
    my @list = ref($_[0]) eq 'ARRAY' ? @{shift @_} : @_;

    $args{min} = exists $args{min} ?  $args{min} <     0 ?     0 : $args{min} :     0;
    $args{max} = exists $args{max} ?  $args{max} > @list ? @list : $args{max} : @list;

    ($args{min}, $args{max}) = ($args{max}, $args{min})
        if $args{max} < $args{min};

    my $lim = 2 ** @list - 1;
    my @powerset;
    while( $lim >= 0 ) {
        my @set;
        my $mask   = $lim--;
        my $offset = 0;
        while( $mask ) {
            push @set, $list[$offset] if $mask & 1;
            $mask >>= 1;
            ++$offset;
        }
        if( @set >= $args{min} and @set <= $args{max} ) {
            push @powerset, exists $args{join}
                ? join( $args{join}, @set)
                : [@set];
        }
    }
    return \@powerset;
}

=back

=head1 METHODS

The object-oriented interface provided by the module is implemented
with the following methods.

=over 8

=item new

Creates a new C<Data::PowerSet> object.

  my $ps = Data::PowerSet->new( qw( foo bar grault waldo ));

A reference to a hash may
be supplied, to change the way the object behaves.

=over 8

=item B<min>

Minimum number of elements present in the selection.

Note that the empty set (no elements) is quite valid, according to
the mathematical definition of a power set. If this is not what you
expect, setting C<min> to 1 will effectively cause the empty set to
be excluded from the result.

  my $ps = Data::PowerSet->new( {min=>2}, 2, 3, 5, 8, 11 );

In the above object, no returned list will contain fewer
than 2 elements.

=item B<max>

Maximum number of elements present in the selection.

  my $ps = Data::PowerSet->new( {max=>3}, 2, 3, 5, 8, 11 );

In the above object, no returned list will contain more
than 3 elements.

=item B<join>

Perform a C<join()> on each returned list using the
specified value.

  my $ps = Data::Powerset->new( {join=>'-'}, 'a', 'b' );

When this attribute is used, the C<next()> method will
return a scalar rather than a reference to an array.

=back

=cut

sub new {
    my $class = shift;
    my %args;
    if( ref($_[0]) eq 'HASH' ) {
        %args = %{shift(@_)};
    }
    if( ref($_[0]) eq 'ARRAY' ) {
        $args{data} = shift @_;
    }
    else {
        $args{data} = [@_],
    }
    $args{current} = 2**@{$args{data}}-1;

    $args{min} =
        exists $args{min}
        ?  $args{min} < 0
            ? 0 : $args{min}
        : 0
    ;

    $args{max} =
        exists $args{max}
        ?  $args{max} > @{$args{data}}
            ? @{$args{data}} : $args{max}
        : @{$args{data}}
    ;

    ($args{min}, $args{max}) = ($args{max}, $args{min})
        if $args{max} < $args{min};
    return bless \%args, $class;
}

=item next

Returns a reference to an array containing the next combination of
elements from the original list;

    my $ps = Data::PowerSet->new(qw(e t a i s o n));
    my $first = $ps->next;
    my $next  = $ps->next;

=cut

sub next {
    my $self = shift;
    my $ok = 0;
    my @set;
    until( $ok ) {
        return undef unless $self->{current} >= 0;
        my $mask   = $self->{current}--;
        my $offset = 0;
        @set = ();
        while( $mask ) {
            push @set, $self->{data}[$offset] if $mask & 1;
            $mask >>= 1;
            ++$offset;
        }
        $ok = 1 if @set >= $self->{min} and @set <= $self->{max};
    }
    return exists $self->{join} ? join($self->{join}, @set) : \@set;
}

=item reset

Restart from the first combination of the list.

=cut

sub reset {
    my $self = shift;
    $self->{current} = 2**@{$self->{data}}-1;
}

=item data

Accept a new list of elements from which to draw combinations.

  $ps->data( qw(all new elements to use) );

=cut

sub data {
    my $self = shift;
    $self->{data} = [@_],
    $self->{current} = 2**@{$self->{data}}-1;

    $self->{min} = @{$self->{data}} if $self->{min} > @{$self->{data}};
    $self->{max} = @{$self->{data}} if $self->{max} > @{$self->{data}};
}

=item count

Returns the number of elements in the set. This can be used
to set C<max> to the number of elements minus one, in order to
exclude the set of all elements, when the number of elements
is difficult to determine beforehand.

=cut

sub count {
    my $self = shift;
    return scalar(@{$self->{data}});
}

=back

=head1 DIAGNOSTICS

None.

=head1 NOTES

Power sets grow exponentially. A power set of 10 elements returns
a more than one thousand results. A power set of 20 elements contains
more than one million results. The module is not expected to be put
to use in larger sets.

A power set, by definition, includes the set of no elements and
the set of all elements. If these results are not desired, the
C<min> and C<max> methods or properties can be used to exclude
them from the results.

This module works with perl version 5.005_04 and above.

=head1 SEE ALSO

=over 8

=item L<List::PowerSet>

Another module that generates power sets. If I had managed to find
it in a search beforehand, I probably would have used it instead.
Nonetheless, C<Data::PowerSet> has a couple of features not
present in C<List::PowerSet>, but otherwise both can be used
pretty much interchangeably.

=item L<Algorithm::Combinatorics>

A fast (no stacks, no recursion) method for generating permutations
and combinations of a set. A power set is merely the union of all
combinations (of differing lengths).

=item L<http://en.wikipedia.org/wiki/Power_set>

The wikipedia definition of a power set.

=back

=head1 BUGS

None known. Please report all bugs at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-PowerSet|rt.cpan.org>

Make sure you include the output from the following two commands:

  perl -MData::PowerSet -le 'print Data::PowerSet::VERSION'
  perl -V

=head1 ACKNOWLEDGEMENTS

This module is dedicated to Estelle Souche, who pointed out the very
elegant and obvious algorithm. Smylers suggested the name.

=head1 AUTHOR

David Landgren, copyright (C) 2005-2008. All rights reserved.

http://www.landgren.net/perl/

If you (find a) use this module, I'd love to hear about it.
If you want to be informed of updates, send me a note. You
know my first name, you know my domain. Can you guess my
e-mail address?

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

'The Lusty Decadent Delights of Imperial Pompeii';
