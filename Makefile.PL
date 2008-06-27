use inc::Module::Install;

name 'Email-Address-Loose';
all_from 'lib/Email/Address/Loose.pm';

requires 'Email::Address';

build_requires 'Email::Address';

tests 't/*.t t/*/*.t';

auto_include;

WriteAll;
