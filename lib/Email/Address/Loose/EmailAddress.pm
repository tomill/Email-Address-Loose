package Email::Address::Loose::EmailAddress;
use Email::Address::Loose::EmailValidLoose;

## no critic
# Note: The following code were copied from Email::Address 1.889

use strict;
## no critic RequireUseWarnings
# support pre-5.6

use vars qw[$VERSION $COMMENT_NEST_LEVEL $STRINGIFY
            $COLLAPSE_SPACES
            %PARSE_CACHE %FORMAT_CACHE %NAME_CACHE
            $addr_spec $angle_addr $name_addr $mailbox];

my $NOCACHE;

$VERSION              = '1.889';
$COMMENT_NEST_LEVEL ||= 2;
$STRINGIFY          ||= 'format';
$COLLAPSE_SPACES      = 1 unless defined $COLLAPSE_SPACES; # who wants //=? me!


my $CTL            = q{\x00-\x1F\x7F};
my $special        = q{()<>\\[\\]:;@\\\\,."};

my $text           = qr/[^\x0A\x0D]/;

my $quoted_pair    = qr/\\$text/;

my $ctext          = qr/(?>[^()\\]+)/;
my ($ccontent, $comment) = (q{})x2;
for (1 .. $COMMENT_NEST_LEVEL) {
  $ccontent = qr/$ctext|$quoted_pair|$comment/;
  $comment  = qr/\s*\((?:\s*$ccontent)*\s*\)\s*/;
}
my $cfws           = qr/$comment|\s+/;

my $atext          = qq/[^$CTL$special\\s]/;
my $atom           = qr/$cfws*$atext+$cfws*/;
my $dot_atom_text  = qr/$atext+(?:\.$atext+)*/;
my $dot_atom       = qr/$cfws*$dot_atom_text$cfws*/;

my $qtext          = qr/[^\\"]/;
my $qcontent       = qr/$qtext|$quoted_pair/;
my $quoted_string  = qr/$cfws*"$qcontent+"$cfws*/;

my $word           = qr/$atom|$quoted_string/;

# XXX: This ($phrase) used to just be: my $phrase = qr/$word+/; It was changed
# to resolve bug 22991, creating a significant slowdown.  Given current speed
# problems.  Once 16320 is resolved, this section should be dealt with.
# -- rjbs, 2006-11-11
#my $obs_phrase     = qr/$word(?:$word|\.|$cfws)*/;

# XXX: ...and the above solution caused endless problems (never returned) when
# examining this address, now in a test:
#   admin+=E6=96=B0=E5=8A=A0=E5=9D=A1_Weblog-- ATAT --test.socialtext.com
# So we disallow the hateful CFWS in this context for now.  Of modern mail
# agents, only Apple Web Mail 2.0 is known to produce obs-phrase.
# -- rjbs, 2006-11-19
my $simple_word    = qr/$atom|\.|\s*"$qcontent+"\s*/;
my $obs_phrase     = qr/$simple_word+/;

my $phrase         = qr/$obs_phrase|(?:$word+)/;

my $local_part     = Email::Address::Loose::EmailValidLoose->peek_local_part; # Note: this line was replaced!! qr/$dot_atom|$quoted_string/;
my $dtext          = qr/[^\[\]\\]/;
my $dcontent       = qr/$dtext|$quoted_pair/;
my $domain_literal = qr/$cfws*\[(?:\s*$dcontent)*\s*\]$cfws*/;
my $domain         = qr/$dot_atom|$domain_literal/;

my $display_name   = $phrase;


$addr_spec  = qr/$local_part\@$domain/;
$angle_addr = qr/$cfws*<$addr_spec>$cfws*/;
$name_addr  = qr/$display_name?$angle_addr/;
$mailbox    = qr/(?:$name_addr|$addr_spec)$comment*/;

sub _PHRASE   () { 0 }
sub _ADDRESS  () { 1 }
sub _COMMENT  () { 2 }
sub _ORIGINAL () { 3 }
sub _IN_CACHE () { 4 }


sub __get_cached_parse {
    return if $NOCACHE;

    my ($class, $line) = @_;

    return @{$PARSE_CACHE{$line}} if exists $PARSE_CACHE{$line};
    return; 
}

sub __cache_parse {
    return if $NOCACHE;
    
    my ($class, $line, $addrs) = @_;

    $PARSE_CACHE{$line} = $addrs;
}

sub parse {
    my ($class, $line) = @_;
    return unless $line;

    $line =~ s/[ \t]+/ /g if $COLLAPSE_SPACES;

    if (my @cached = $class->__get_cached_parse($line)) {
        return @cached;
    }

    my (@mailboxes) = ($line =~ /$mailbox/go);
    my @addrs;
    foreach (@mailboxes) {
      my $original = $_;

      my @comments = /($comment)/go;
      s/$comment//go if @comments;

      my ($user, $host, $com);
      ($user, $host) = ($1, $2) if s/<($local_part)\@($domain)>//o;
      if (! defined($user) || ! defined($host)) {
          s/($local_part)\@($domain)//o;
          ($user, $host) = ($1, $2);
      }

      my ($phrase)       = /($display_name)/o;

      for ( $phrase, $host, $user, @comments ) {
        next unless defined $_;
        s/^\s+//;
        s/\s+$//;
        $_ = undef unless length $_;
      }

      my $new_comment = join q{ }, @comments;
      push @addrs,
        $class->new($phrase, "$user\@$host", $new_comment, $original);
      $addrs[-1]->[_IN_CACHE] = [ \$line, $#addrs ]
    }

    $class->__cache_parse($line, \@addrs);
    return @addrs;
}



1;
