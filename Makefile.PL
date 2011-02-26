use inc::Module::Install;

name 'Email-Address-Loose';
all_from 'lib/Email/Address/Loose.pm';

requires 'Email::Address' => 1.889;

build_requires 'Email::Address';
auto_include;

tests_recursive;

WriteAll;
