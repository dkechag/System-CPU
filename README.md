# NAME

System::CPU - Cross-platform CPU information / topology

# SYNOPSIS

    use System::CPU;

    # Number of logical cores. E.g. on SMT systems these will be Hyper-Threads
    my $logical_cpu = System::CPU::get_ncpu();

    # On some platforms you can also get the number of processors and physical cores
    my ($phys_processors, $phys_cpu, $logical_cpu) = System::CPU::get_cpu();

    # Model name of the CPU
    my $name = System::CPU::get_name();

    # CPU Architecture
    my $arch = System::CPU::get_arch();

# DESCRIPTION

A pure Perl module with no dependencies to get basic CPU information on any platform.
The data you can get differs depending on platform, but for many systems running
Linux/BSD/MacOS you can get extra nuance like number of threads vs cores etc.

It was created for [Benchmark::DKbench](https://metacpan.org/pod/Benchmark%3A%3ADKbench) with the `get_ncpu` function modeled
after the one on [MCE::Util](https://metacpan.org/pod/MCE%3A%3AUtil). In fact, some code was copied from that function as
it had the most reliable way to consistently get the logical cpus of the system.

# FUNCTIONS

## get\_cpu

Returns as detailed CPU topology as the platform allows. A list of three values
will be returned, the first and the second possibly `undef`:

    my ($phys_processors, $phys_cpu, $logical_cpu) = System::CPU::get_cpu();

For many Linux systems, the number of physical processors (sockets), as well as
the number of physical CPU cores and logical CPUs (CPU threads) will be returned.

For MacOS and BSD, the physical processors (sockets) will be `undef`, but the
cores vs threads numbers should still be available for most systems.

For the systems where the extra information is not available (i.e. all other OSes),
the first two values will be `undef`.

## get\_ncpu

    my $logical_cpus = System::CPU::get_ncpu();

This function behaves very similar to `MCE::Util::get_ncpu` - in fact code is borrowed
from it. The number of logical CPUs will be returned, this is the number of hyper-threads
for SMT systems and the number of cores for most others.

## get\_name

    my $cpu_name = System::CPU::get_name(raw => $raw?);

Returns the CPU model name. By default it will remove some extra spaces and Intel's
(TM) and (R), but you can pass in the `raw` argument to avoid this cleanup.

## get\_arch

    my $arch = System::CPU::get_arch();

Will return the CPU architecture as reported by the system. There is no standarized
form, e.g. Linux will report aarch64 on a system where Darwin would report arm64
etc.

# CAVEATS

Since text output from user commands is parsed for most platforms, only the English
language locales are supported.

# NOTES

I did try to use existing solutions before writing my own. [Sys::Info](https://metacpan.org/pod/Sys%3A%3AInfo) has issues
installing on modern Linux systems (I tried submitting a PR, but the author seems
unresponsive).

[System::Info](https://metacpan.org/pod/System%3A%3AInfo) is the most promising, however, it returns a simple "core" count which
seems to inconsistently be either physical cores or threads depending on the platform.
The author got back to me, so I will try to sort that out, as that module is more
generic than System::CPU.

There are also several platform-specific modules, most requiring a compiler too
(e.g. [Unix::Processors](https://metacpan.org/pod/Unix%3A%3AProcessors), [Sys::Info](https://metacpan.org/pod/Sys%3A%3AInfo), various `*::Sysinfo`).

In the end, I wanted to get the CPU topology where possible - number of processors/sockets,
cores, threads separately, something that wasn't readily available.

I intend to support all systems possible with this simple pure Perl module. If you
have access to a system that is not supported or where the module cannot currently
give you the correct output, feel free to contact me about extending support.

Currently supported systems:

Linux/Android, BSD/MacOS, Win32/Cygwin, AIX, Solaris, IRIX, HP-UX, Haiku, GNU
and variants of those.

# AUTHOR

Dimitrios Kechagias, `<dkechag at cpan.org>`

# BUGS

Please report any bugs or feature requests to [https://github.com/dkechag/System-CPU/issues](https://github.com/dkechag/System-CPU/issues).

You can also submit PRs with fixes/enhancements directly.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc System::CPU

You can also look for information at:

- GitHub

    [https://github.com/dkechag/System-CPU](https://github.com/dkechag/System-CPU)

- Search CPAN

    [https://metacpan.org/release/System-CPU](https://metacpan.org/release/System-CPU)

# ACKNOWLEDGEMENTS

Some code borrowed from [MCE](https://metacpan.org/pod/MCE).

# LICENSE AND COPYRIGHT

This software is copyright (c) 2023 by Dimitrios Kechagias.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
