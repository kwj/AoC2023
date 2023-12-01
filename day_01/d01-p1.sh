#!/bin/sh

# Day 1: Part one

if [ $# = 0 ]; then
    echo "Usage: $0 <input file>"
else
    sed -E -e 's/^[^0-9]+//' -e 's/[^0-9]+$//' $1 |
    sed -E -e 's/^(.)$/\1\1/' -e 's/^(.).*(.)$/\1\2/' |
    paste -s -d+ |
    bc
fi
