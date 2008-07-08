package Email::Address::Loose;
use strict;
use warnings;
our $VERSION = '0.01';

use base qw( Email::Address );

use Email::Address::Loose::EmailAddress;

sub parse {
    Email::Address::Loose::EmailAddress::parse(@_);
}

my $Email_Address_parse;

sub import {
    my ($class, @args) = @_;
    if (grep { $_ eq '-override' } @args) {
        $class->globally_override;
    }
}

sub globally_override {
    my $class = shift;

    no warnings 'redefine';
    unless ($Email_Address_parse) {
        $Email_Address_parse = \&Email::Address::parse;
        *Email::Address::parse = \&parse;
    }

    1;
}

sub globally_unoverride {
    my $class = shift;

    no warnings 'redefine';
    if ($Email_Address_parse) {
        *Email::Address::parse = $Email_Address_parse;
        undef $Email_Address_parse;

        Email::Address->purge_cache;
    }

    1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Email::Address::Loose - Make Email::Address->parse() loose

=head1 SYNOPSIS

  my $address = 'read..rfc822.@docomo.ne.jp'; # Email::Addess can't find
  
  use Email::Address::Loose;
  my @emails = Email::Address::Loose->parse($address); # findable
   
  use Email::Address;
  use Email::Address::Loose;
  
  Email::Address::Loose->globally_override;
  my @emails = Email::Address->parse($address); # findable
  
  use Email::Address;
  use Email::Address::Loose -override;
  my @emails = Email::Address->parse($address); # findable
  
=head1 DESCRIPTION

Email::Address::Loose is-a L<Email::Address>, but C<parse()> is "loose" as
L<Email::Valid::Loose>.

=head1 EXTENDED METHODS

=over 4

=item parse( $addresses )

  my ($email) = Email::Address::Loose->parse('Docomo <read_rfc822.@docomo.ne.jp>');

see L<Email::Address/parse>.

=back

=head1 ORIGINAL METHODS

=over 4

=item globally_override

  Email::Address::Loose->globally_override;

Now changes Email::Address->parse into Email::Address::Loose->parse.

  use Email::Address::Loose -override;

Same thing, compile time.

=item globally_unoverride

  Email::Address::Loose->globally_unoverride;

Restores override-ed C<< Email::Address->parse >>.

=back

=head1 AUTHOR

Naoki Tomita E<lt>tomita@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Email::Address>, L<Email::Valid::Loose>

L<http://coderepos.org/share/browser/lang/perl/Email-Address-Loose> (repository)

=cut
