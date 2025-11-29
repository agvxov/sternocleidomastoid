#!/usr/bin/perl

use strict;
use warnings;
use File::Slurp 'slurp';

my $s;

if (@ARGV >= 2) {
    $s = slurp($ARGV[1]);
} else {
    local $/;
    $s = <STDIN>;
}

my $indent = 0;
for my $i (0 .. length($s)-1) {
    my $c = substr($s, $i, 1);
    if ($c eq '(') {
        ++$indent;
    } elsif ($c eq ')') {
        --$indent;
    } elsif ($c eq ' ') {
        print "\n" . (' ' x ($indent*4));
        next;
    }

    print $c;
}
