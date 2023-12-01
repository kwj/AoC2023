import argparse
import sys

# It looks like that 'oneight' is equal to '1.*8' not '1ight'.


def replace_number_letters(s):
    n_letters = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    cands = list(
        filter(
            lambda x: x[0] != -1,
            map(lambda x: [s.find(x[1]), x[0], x[1]], enumerate(n_letters, 1)),
        )
    )

    if len(cands) == 0:
        return s
    else:
        target_num, target_str = min(cands, key=lambda x: x[0])[1:]
        return replace_number_letters(
            s.replace(
                target_str,
                str(target_num) + target_str[1:],  # Please see the above comment.
                1,
            )
        )


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', nargs='?', type=argparse.FileType(), default=sys.stdin)
    args = parser.parse_args()
    with args.infile as f:
        for line in f:
            print(replace_number_letters(line), end='')
