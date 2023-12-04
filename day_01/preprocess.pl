#!/usr/bin/env perl

use strict;
use warnings;

sub replace_number_letters {
    my $s = shift(@_);
    my @n_letters = qw(one two three four five six seven eight nine);
    
    my @cands = sort {$a->[0] <=> $b->[0]} grep {$_->[0] != -1} map {[index($s, $n_letters[$_]), $n_letters[$_], $_ + 1]} 0..$#n_letters;

    if (!@cands) {
        return $s;
    } else {
        my $offset = $cands[0][0];
        my $num = $cands[0][2];
        substr($s, $offset, 1, "$num");
        replace_number_letters($s);
    }
}

while (<>) {
    chomp;
    print replace_number_letters($_) . "\n";
}