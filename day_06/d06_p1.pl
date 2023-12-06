#!/usr/bin/env perl

# Day 6: Part one

use strict;
use warnings;

use List::Util qw(reduce zip);
use POSIX qw(ceil floor);

sub get_nways {
    my ($t, $d) = @_;

    my $sq = sqrt($t * $t - 4 * $d);
    my $low = floor((($t - $sq) / 2) + 1);
    my $high = ceil((($t + $sq) / 2) - 1);

    return $high - $low + 1;
}

my @limit = split(/\s+/, <>);
shift @limit;

my @record = split(/\s+/, <>);
shift @record;

print((reduce { $a * $b } map { my ($t, $d) = @$_; get_nways($t, $d) } (zip \@limit, \@record)) . "\n");
