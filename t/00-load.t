#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'System::CPU' ) || print "Bail out!\n";
}

diag( "Testing System::CPU $System::CPU::VERSION, Perl $], $^X" );

warn "System ($^O): ". join(
    ", ",
    map {$_ || 'undef'} System::CPU::get_cpu(), System::CPU::get_name(), System::CPU::get_arch()
    ) . "\n"
    if $ENV{EXTENDED_TESTING} || $ENV{AUTOMATED_TESTING};
