package Sort::Key::Register;

our $VERSION = '1.30';

use warnings;
use strict;

use Sort::Key;

sub import {
    my $class = shift;
    my $name = shift;
    if (@_ == 1) {
	Sort::Key::Types::register_type($name, undef, @_);
    }
    else {
	Sort::Key::Types::register_type($name, @_);
    }
}

1;
__END__

=head1 NAME

Sort::Key::Register - tell Sort::Key how to sort new data types.

=head1 SYNOPSIS

  use Sort::Key::Register Person =>
      sub { $_->surname, $_->name },
      qw(string string);

  use Sort::Key::Register 'Color::Component' => 'integer';

  use Sort::Key::Register Color =>
      sub { $_->R, $_->G, $_->B },
      ('Color::Component') x 3;


=head1 DESCRIPTION

Sort::Key::Register allows one to register new data types with
Sort::Key so that they can be sorted as natively supported ones.

It works as a pragma module and doesn't export any function, all its
functionality is provided via C<use>:

  use Sort::Key::Register ...

To avoid collisions between modules registering types with the same
name, you should qualify them with the package name.

  use Sort::Key::Register 'MyPkg::foo' => sub { $_ }, '-int';

  # or using __PACKAGE__:
  use Sort::Key::Register __PACKAGE__, sub { $_ }, '-int';

=head2 USAGE

=over 4

=item use Sort::Key::Register $name => \&multikeygen, @keytypes;

registers type C<$name>.

C<&multikeygen> is the multi-key extraction function for the type and
C<@keytypes> are the types of the extracted keys.

=item use Sort::Key::Register $name => $keytype;

this 'use' is useful for simple types that are sorted as another type
already registered, maybe changing the direction of the sort
(ascending or descending).

=back

=head1 SEE ALSO

L<Sort::Key>, L<Sort::Key::Maker>.

=head1 AUTHOR

Salvador FandiE<ntilde>o, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005, 2014 by Salvador FandiE<ntilde>o

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
