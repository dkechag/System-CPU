package System::CPU;

use 5.006;
use strict;
use warnings;

=head1 NAME

System::CPU - The great new System::CPU!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use System::CPU;

    my $foo = System::CPU->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub get_cpu {
    return _linux_cpu() if $^O =~ /linux|android/i;
    return _bsd_cpu() if $^O =~ /bsd|darwin|dragonfly/i;
    return _solaris_cpu() if $^O =~ /osf|solaris|sunos|svr5|sco/i;
    return _aix_cpu() if $^O =~ /aix/i;
    return _gnu_cpu() if $^O =~ /gnu/i;
    return _haiku_cpu() if $^O =~ /haiku/i;
    return _irix_cpu() if $^O =~ /irix/i;
    return (undef, undef, $ENV{NUMBER_OF_PROCESSORS}) if $^O =~ /mswin|mingw|msys|cygwin/i;
    return (undef, undef, grep { /^processor/ } `ioscan -fkC processor 2>/dev/null`) if $^O =~ /hp-?ux/i;
}

sub get_ncpu {
    my $ncpu = get_cpu();
    return $ncpu;
}

sub get_name {
    if ($^O =~ /linux|android/) {
        my ($name) = _proc_cpuinfo();
        return $name;
    }
    return $ENV{PROCESSOR_IDENTIFIER} if $^O =~ /mswin|mingw|msys|cygwin/i;
}

sub get_arch {
    return _uname_m() if $^O =~ /linux|android|bsd|darwin|dragonfly|gnu|osf|solaris|sunos|svr5|sco|hp-?ux/i;
    return $ENV{PROCESSOR_ARCHITECTURE} if $^O =~ /mswin|mingw|msys|cygwin/i;
    return _uname_p() if $^O =~ /aix|irix/i;
    return _getarch() if $^O =~ /haiku/i;
}

sub _solaris_cpu {
    my $ncpu;
    if (-x '/usr/sbin/psrinfo') {
        my $count = grep {/on-?line/} `psrinfo 2>/dev/null`;
        $ncpu = $count if $count;
    } else {
        my @output = grep {/^NumCPU = \d+/} `uname -X 2>/dev/null`;
        $ncpu = (split ' ', $output[0])[2] if @output;
    }
    return $ncpu;
}

sub _bsd_cpu {
    chomp( my $cpus = `sysctl -n hw.ncpu 2>/dev/null` );
    chomp( $cpus = `sysctl -n hw.logicalcpu_max 2>/dev/null` ) unless $cpus;
    return unless $cpus;
    chomp( my $cores = `sysctl -n hw.physicalcpu_max 2>/dev/null` );
    $cores ||= $cpus;
    return (undef, $cores, $cpus);
}

sub _linux_cpu {
   my ($name, $phys, $cores, $cpus) = _proc_cpuinfo();
   return $phys, $cores, $cpus;
}

sub _aix_cpu {
    my $ncpu;
    my @output = `lparstat -i 2>/dev/null | grep "^Online Virtual CPUs"`;
    if (@output) {
        $output[0] =~ /(\d+)\n$/;
        $ncpu = $1 if $1;
    }
    if (!$ncpu) {
        @output = `pmcycles -m 2>/dev/null`;
        if (@output) {
            $ncpu = scalar @output;
        } else {
            @output = `lsdev -Cc processor -S Available 2>/dev/null`;
            $ncpu   = scalar @output if @output;
        }
    }
    return (undef, undef, $ncpu);
}

sub _haiku_cpu {
    my $ncpu;
    my @output = `sysinfo -cpu 2>/dev/null | grep "^CPU #"`;
    $ncpu = scalar @output if @output;
    return $ncpu;
}

sub _irix_cpu {
    my $ncpu;
    my @out = grep {/\s+processors?$/i} `hinv -c processor 2>/dev/null`;
    $ncpu = (split ' ', $out[0])[0] if @out;
    return $ncpu;
}

sub _gnu_cpu {
    my $ncpu;
    chomp(my @output = `nproc --all 2>/dev/null`);
    $ncpu = $output[0] if @output;
    return $ncpu;
}

sub _proc_cpuinfo {
    my (@physical, @cores, $phys, $cpus, $name);
    if ( -f '/proc/cpuinfo' && open my $fh, '<', '/proc/cpuinfo' ) {
        while (<$fh>) {
            $cpus++ if /^processor\s*:/i;
            push @physical, $1 if /^physical id\s*:\s*(\d+)/i;
            push @cores, $1 if /^cpu cores\s*:\s*(\d+)/i;
            $name = $1 if /^model name\s*:\s*(.*)/i;
        }
        return $name, undef, $cores[0], $cpus if !@physical && @cores;
        @cores = (0) unless @cores;
        my %hash;
        $hash{$physical[$_]} = $_ < scalar(@cores) ? $cores[$_] : $cores[0]
            for 0 .. $#physical;
        my $phys  = keys %hash || undef;
        my $cores = sum(values %hash) || $cpus;
        return $name, $phys, $cores, $cpus;
    }
    return;
}

sub _uname_m {
    chomp( my $arch = `uname -m 2>/dev/null` );
    return $arch || _uname_p();
}

sub _uname_p {
    chomp( my $arch = `uname -p 2>/dev/null` );
    return $arch;
}

sub _getarch {
    chomp( my $arch = `getarch 2>/dev/null` );
    return $arch;
}

=head1 AUTHOR

Dimitrios Kechagias, C<< <dkechag at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-system-cpu at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=System-CPU>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc System::CPU


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=System-CPU>

=item * GitHub issue tracker

L<https://github.com/dkechag/System-CPU/issues>

=item * Search CPAN

L<https://metacpan.org/release/System-CPU>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2023 by Dimitrios Kechagias.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

1; # End of System::CPU
