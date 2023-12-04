#!/usr/bin/env perl

# It looks like that 'oneight' is equal to '1.*8.*' not '1ight'.
# I therefore replace a numeric word as following.
#
#   'one' -> 'one1one'
#   'oneight' -> 'one1oneight8eight'

use v5.12;
use strict;
use warnings;

sub replace_number_letters {
    my $s = shift(@_);
    my @n_letters = qw(one two three four five six seven eight nine);

    while (my ($idx, $word) = each @n_letters) {
        $idx += 1;
        $s =~ s/${word}/${word}${idx}${word}/g;
    }

    return $s;
}

while (<>) {
    chomp;
    print replace_number_letters($_) . "\n";
}
