use strict;
use Test::More;

use Email::Address::Loose;

my @ok = (
    'miyagawa@cpan.org',
    'rfc822.@docomo.ne.jp',
    '-everyone..-_-..annoyed-@docomo.ne.jp',
    '-aaaa@foobar.ezweb.ne.jp',
);

plan tests => @ok * 2;

for my $address (@ok) {
    my @emails = Email::Address::Loose->parse($address);
    ok @emails == 1, $address;
    is $emails[0]->address, $address;
}
