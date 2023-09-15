use Test2::V0;

our $mock_return;
our $mock_cmd;

BEGIN {
    *CORE::GLOBAL::readpipe = sub {
        my $cmd = shift;
        return $mock_return if $cmd =~ /$mock_cmd/;
        return `$cmd`
    };
};

my $mockfile = eval "require Test::MockFile";
eval "use System::CPU";

subtest "get_cpu" => sub {
    foreach my $test (get_cpu_tests()) {
        local $^O = $test->[0];
        my $mock;
        $mock = Test::MockFile->file($test->[2], $test->[3]) if $test->[1] eq 'file';
        ($mock_cmd, $mock_return) = ($test->[2], $test->[3]) if $test->[1] eq 'cmd';
        is([System::CPU::get_cpu], $test->[4], "get_cpu $^O");
        is(System::CPU::get_ncpu, $test->[4]->[2], "get_ncpu $^O");
    }
};


sub get_cpu_tests {
    return (
['linux', 'file', '/proc/cpuinfo', undef, [undef, undef, undef],
['android', 'file', '/proc/cpuinfo', 'processor  : 0
BogoMIPS    : 48.00
Features    : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp flagm2 frint
CPU implementer : 0x00
CPU architecture: 8
CPU variant : 0x0
CPU part    : 0x000
CPU revision    : 0

processor   : 1
BogoMIPS    : 48.00
Features    : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma lrcpc dcpop sha3 asimddp sha512 asimdfhm dit uscat ilrcpc flagm ssbs sb paca pacg dcpodp flagm2 frint
CPU implementer : 0x00
CPU architecture: 8
CPU variant : 0x0
CPU part    : 0x000
CPU revision    : 0
', [undef, 2, 2]],
['linux', 'file', '/proc/cpuinfo', 'processor   : 0
physical id : 0
core id     : 0
cpu cores   : 1

processor   : 1
physical id : 0
core id     : 0
cpu cores   : 1

processor   : 2
physical id : 1
core id     : 0
cpu cores   : 1

processor   : 3
physical id : 1
core id     : 0
cpu cores   : 1
',[2, 2, 4]]
);
}