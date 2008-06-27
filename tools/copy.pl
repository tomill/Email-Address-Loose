use strict;
use warnings;
use LWP::Simple;
use FindBin;

copy_email_valid_loose('0.05');
copy_email_address('1.889');
exit;

sub copy_email_valid_loose {
    my $version = shift;
    
    my $module = get("http://search.cpan.org/src/MIYAGAWA/Email-Valid-Loose-$version/lib/Email/Valid/Loose.pm")
        or die $!;

    my $header = <<HEAD
package Email::Address::Loose::EmailValidLoose;

# Note: The following code were copied from Email::Valid::Loose $version
HEAD
    ;
    
    $module =~ s/^package Email::Valid::Loose;/$header/m;
    $module =~ s/^=.+?^=cut\n//msg; # strip pod
    $module =~ s/^(use Email::Valid.+)/# $1 # Note: don't need/m;
    $module =~ s/^(use base.+)/# $1 # Note: don't need/m;
    $module =~ s/^sub rfc822 {.*//ms;
    $module .= "sub peek_local_part { qr/\$local_part/ } # Note: added!!\n1;\n";
     
    open(my $fh, '>', "$FindBin::Bin/../lib/Email/Address/Loose/EmailValidLoose.pm")
        or die $!;
    print $fh $module;
    close $fh;
}

sub copy_email_address {
    my $version = shift;
    
    my $module = get("http://emailproject.perl.org/svn/Email-Address/tags/$version/lib/Email/Address.pm")
        or die $!;

    my $header = <<HEAD
package Email::Address::Loose::EmailAddress;
use Email::Address::Loose::EmailValidLoose;

## no critic
# Note: The following code were copied from Email::Address $version
HEAD
    ;
    
    $module =~ s/^package Email::Address;/$header/m;
    $module =~ s/^=.+?^=cut\n//msg; # strip pod
    $module =~ s/^(my \$local_part\s+=)(.*)/$1 Email::Address::Loose::EmailValidLoose->peek_local_part; # Note: this line was replaced!!$2/m;
    $module =~ s/^sub new {.*/\n1;\n/ms;
    
    open(my $fh, '>', "$FindBin::Bin/../lib/Email/Address/Loose/EmailAddress.pm")
        or die $!;
    print $fh $module;
    close $fh;

    system("svn -q --force export http://emailproject.perl.org/svn/Email-Address/tags/$version/t $FindBin::Bin/../t/regression-email-address")
        and die $!;
    
    system("rm $FindBin::Bin/../t/regression-email-address/pod*")
        and die $!;

    system("perl -pi -e 's/(Email::Address)/\$1::Loose/g' $FindBin::Bin/../t/regression-email-address/*.t")
        and die $!;
}
