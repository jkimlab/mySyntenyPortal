package Sort::Key::Types;

our $VERSION = '1.30';

use strict;
use warnings;
use Carp;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(register_type);

our $DEBUG;
$DEBUG ||= 0;

# this hash is also used from Sort::Key::Multi to find out which
# letters can be used as types:

our %mktypes = ( s => 0,
                 l => 1,
                 n => 2,
                 i => 3,
                 u => 4 );

sub _mks2n {
    if (my ($rev, $key)=$_[0]=~/^([-+]?)(.)$/) {
	exists $mktypes{$key}
	    or croak "invalid multi-key type '$_[0]'";
	my $n = $mktypes{$key};
	$n+=128 if $rev eq '-';
	return $n
    }
    die "internal error, bad key '$_[0]'";
}

our %mkmap = qw(str s
		string s
		locale l
		loc l
		lstr l
		int i
		integer i
		uint u
		unsigned_integer u
		number n
		num n);

$_ = [$_] for (values %mkmap);
our %mksub = map { $_ => undef } keys %mkmap;

sub _get_map {
    my ($rev, $name) = $_[0]=~/^([+-]?)(.*)$/;
    exists $mkmap{$name}
	or croak "unknown key type '$name'\n";
    if ($rev eq '-') {
	return map { /^-(.*)$/ ? $1 : "-$_" } @{$mkmap{$name}}
    }
    @{$mkmap{$name}}
}

sub _get_sub {
    $_[0]=~/^[+-]?(.*)$/;
    exists $mksub{$1}
	or croak "unknown key type '$1'\n";
    return $mksub{$1}
}

sub _combine_map { map { _get_map $_ } @_ }

use constant _nl => "\n";

sub combine_types { pack('C*', (map { _mks2n $_ } _combine_map(@_))) }

sub combine_sub {
    my $sub = shift;
    my $for = shift;
    $for = defined $for ? " for $for" : "";

    my @subs = map { _get_sub $_ } @_;

    if ($sub) {
	my $code = 'sub { '._nl;
	if (ref $sub eq 'CODE') {
	    unless (grep { defined $_ } @subs) {
		return $sub
	    }
	    $code.= 'my @keys = &{$sub};'._nl;
	}
	else {
	    if ($sub eq '@_') {
		return undef unless grep {defined $_} @subs;
	    }
	    $code.= 'my @keys = '.$sub.';'._nl;
	}
	$code.= 'print "in: |@keys|\n";'._nl if $DEBUG;

	$code.= '@keys == '.scalar(@_)
	  . ' or croak "wrong number of keys generated$for '
	    . '(expected '.scalar(@_).', returned ".scalar(@keys).")";'._nl;

	{ # new scope so @map doesn't get captured
	    my @map = _combine_map @_;
	    if (@map==@_) {
		for my $i (0..$#_) {
		    if (defined $subs[$i]) {
			$code.= '{ local $_ = $keys['.$i.']; ($keys['.$i.']) = &{$subs['.$i.']}() }'._nl;
		    }
		}
		$code.='print "out: |@keys|\n";'._nl if $DEBUG;
		$code.='return @keys'._nl;
	    }
	    else {
		$code.='my @keys1;'._nl;
		for my $i (0..$#_) {
		    if (defined $subs[$i]) {
			$code.= '{ local $_ = shift @keys; push @keys1, &{$subs['.$i.']}() }'._nl;
		    }
		    else {
			$code.= 'push @keys1, shift @keys;'._nl;
		    }
		}
		$code.='print "out: |@keys1|\n";'._nl if $DEBUG;
		$code.='return @keys1'._nl;
	    }
	}
	$code.='}'._nl;
	print "CODE$for:\n$code----\n" if $DEBUG >= 2;
	my $map = eval $code;
	$@ and die "internal error: code generation failed ($@)";
	return $map;
    }
    else {
	@_==1 or croak "too many keys or keygen subroutine undefined$for";
	return @subs;
    }
}

sub register_type {
    my $name = shift;
    my $sub = shift;
    $name=~/^\w+(?:::\w+)*$/
	or croak "invalid type name '$name'";
    @_ or
	croak "too few keys";
    (exists $mkmap{$name} or exists $mktypes{$name})
	and croak "type '$name' already registered or reserved in ".__PACKAGE__;
    $mkmap{$name} = [ _combine_map @_ ];
    $mksub{$name} = combine_sub $sub, $name, @_;
    ()
}


1;

__END__

=head1 Sort::Key::Types - handle Sort::Key data types

=head1 SYNOPSIS

  use Sort::Key::Types qw(register_type);
  register_type(Color => sub { $_->R, $_->G, $_->B }, qw(int, int, int));

  # you better
  # use Sort::Key::Register ...


=head1 DESCRIPTION

The L<Sort::Key> family of modules can be extended to support new key
types using this module (or the more friendly L<Sort::Key::Register>).

=head2 FUNCTIONS

The following functions are provided:

=over 4

=item Sort::Key::register_type($name, \&gensubkeys, @subkeystypes)

registers a new datatype named C<$name> defining how to convert it to
a multi-key.

C<&gensubkeys> should convert the object of type C<$name> passed on
C<$_> to a list of values composing the multi-key.

C<@subkeystypes> is the list of types for the generated multi-keys.

For instance:

  Sort::Key::Types::register_type
                 'Person',
                 sub { $_->surname,
                       $_->name,
                       $_->middlename },
                 qw(str str str);

  Sort::Key::Types::register_type
                 'Color',
                 sub { $_->R, $_->G, $_->B },
                 qw(int int int);

Once a datatype has been registered it can be used in the same way
as types supported natively, even for defining new types, i.e.:

  Sort::Key::Types::register_type
                 'Family',
                 sub { $_->father, $_->mother },
                 qw(Person Person);

=back

=head1 SEE ALSO

L<Sort::Key>, L<Sort::Key::Merger>, L<Sort::Key::Register>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2007, 2014 by Salvador FandiE<ntilde>o,
E<lt>sfandino@yahoo.comE<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
