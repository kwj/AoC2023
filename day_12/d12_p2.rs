// Day 12: Part two

use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::io::{self, BufReader};
use std::path::Path;

fn main() {
    let fname: String = env::args().nth(1).expect("no given filename");

    let mut ans: i64 = 0;
    if let Ok(lines) = read_lines(fname) {
        for line in lines {
            if let Ok(s) = line {
                let (conditions, grps) = parse_line(&s, 5);
                ans += arrangements(&conditions, &grps);
            }
        }
    }
    println!("{}", ans);
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(BufReader::new(file).lines())
}

fn parse_line(s: &str, factor: usize) -> (String, String) {
    let v: Vec<&str> = s.split(' ').collect();
    let conditions: String = (1..factor).map(|_| v[0]).fold(v[0].to_string(), |a, b| a + "?" + b);
    let grps = (1..factor).map(|_| v[1]).fold(v[1].to_string(), |a, b| a + "," + b);

    (conditions, grps)
}

fn arrangements(conditions: &str, grps: &str) -> i64 {
    let springs = format!("{}.", conditions);
    let n_springs = springs.len();
    let s: &[u8] = springs.as_bytes();
    let dmg_grps: Vec<usize> = grps
        .split(',')
        .map(|x| x.parse::<usize>().unwrap())
        .collect();
    let n_dmg_grps = dmg_grps.len();

    let mut tbl = vec![vec![vec![0_i64; n_springs + 2]; n_dmg_grps + 2]; n_springs + 1];
    tbl[0][0][0] = 1;
    for i in 0..n_springs {
        for j in 0..=n_dmg_grps {
            for k in 0..=n_springs {
                let n = tbl[i][j][k];
                if n == 0 {
                    continue;
                }
                let ch = s[i];
                if ch == b'#' || ch == b'?' {
                    if k == 0 {
                        // start of damage springs
                        tbl[i + 1][j + 1][k + 1] += n;
                    } else {
                        // consecutive damage springs
                        tbl[i + 1][j][k + 1] += n;
                    }
                }
                if ch == b'.' || ch == b'?' {
                    if k == 0 || k == dmg_grps[j - 1] {
                        tbl[i + 1][j][0] += n;
                    }
                }
            }
        }
    }
    tbl[n_springs][n_dmg_grps][0]
}
