#!perl
use strict;

use Email::Address::Loose;
use Test::More tests => 6;

my $phrase = q{jack!work};
my $email  = 'jack@work.com';

my $ea = Email::Address::Loose->new($phrase, $email);

is(
  $ea->format,
  q{"jack!work" <jack@work.com>},
  'we automatically quote a phrase with ! in it',
);

is($ea->phrase, $phrase, "the phrase method returns the right thing");

my ($ea2) = Email::Address::Loose->parse($ea->format);

is(
  $ea2->format,
  q{"jack!work" <jack@work.com>},
  'round trip format the previously parsed email',
);

is($ea2->phrase, $phrase, "the phrase method returns the right thing");

my ($ea3) = Email::Address::Loose->parse(q{jack!work <jack@work.com>});

is(
  $ea3->format,
  q{"jack!work" <jack@work.com>},
  'given an email with an unquoted !, we quote when formatting',
);

is($ea3->phrase, $phrase, "the phrase method returns the right thing");
