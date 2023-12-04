#!/bin/sh

# Day 1: Part two

if [ $# = 0 ]; then
    echo "Usage: $0 <input file>"
else
    perl preprocess.pl $1 |
    sed -E -e 's/^[^0-9]+//' -e 's/[^0-9]+$//' |
    sed -E -e 's/^(.)$/\1\1/' -e 's/^(.).*(.)$/\1\2/' |
    paste -s -d+ |
    bc
fi
