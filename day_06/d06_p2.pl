#!/usr/bin/env perl

# Day 6: Part two

use strict;
use warnings;

use POSIX qw(ceil floor);

sub get_nways {
    my ($t, $d) = @_;

    my $sq = sqrt($t * $t - 4 * $d);
    my $low = floor((($t - $sq) / 2) + 1);
    my $high = ceil((($t + $sq) / 2) - 1);

    return $high - $low + 1;
}

my $t = [split(/:\s+/, <>)]->[1];
$t =~ s/\s*//g;

my $d = [split(/:\s+/, <>)]->[1];
$d =~ s/\s*//g;

print(get_nways($t, $d) . "\n");
