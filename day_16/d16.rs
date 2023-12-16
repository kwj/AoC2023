// Day 16

use std::collections::HashSet;
use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::io::{self, BufReader, Lines};
use std::path::Path;

/*
  Axis (Cmap)
    0--------> Y
    |
    v
    X
*/

#[derive(Debug)]
struct Cmap {
    grid: Vec<Vec<char>>,
    size_x: usize, // number of rows
    size_y: usize, // number of columuns
}

impl Cmap {
    fn new(grid: Vec<Vec<char>>) -> Cmap {
        let size_x = grid.len();
        let size_y = grid[0].len();
        Cmap {
            grid,
            size_x,
            size_y,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Beam {
    x: usize,
    y: usize,
    dx: usize,
    dy: usize,
}

impl Beam {
    fn new(tpl: (usize, usize, usize, usize)) -> Beam {
        let (x, y, dx, dy) = tpl;
        Beam { x, y, dx, dy }
    }

    fn is_inside(&self, bounds: (usize, usize)) -> bool {
        if self.x >= bounds.0 {
            return false;
        }
        if self.y >= bounds.1 {
            return false;
        }
        true
    }

    fn bounce(&mut self, obj: char) {
        if obj == '/' {
            (self.dx, self.dy) = ((!self.dy).wrapping_add(1), (!self.dx).wrapping_add(1));
        } else {
            (self.dx, self.dy) = (self.dy, self.dx);
        }
    }

    fn next_step(&mut self) {
        self.x = self.x.wrapping_add(self.dx);
        self.y = self.y.wrapping_add(self.dy);
    }
}

struct Energized {
    tiles: Vec<i64>,
    size_x: usize,
    _size_y: usize,
}

impl Energized {
    fn new(size_x: usize, _size_y: usize) -> Energized {
        Energized {
            tiles: vec![0; size_x * _size_y],
            size_x,
            _size_y,
        }
    }

    fn on(&mut self, x: usize, y: usize) {
        self.tiles[x * self.size_x + y] = 1
    }

    fn countup(self) -> i64 {
        self.tiles.iter().sum()
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(BufReader::new(file).lines())
}

fn parse_data(it: Lines<BufReader<File>>) -> Result<Vec<Vec<char>>, std::io::Error> {
    let mut ret: Vec<Vec<char>> = Vec::new();

    for line_result in it {
        let v = line_result?.chars().collect::<Vec<char>>();
        ret.push(v);
    }
    Ok(ret)
}

fn solve(cmap: &Cmap, init_beam: Beam) -> i64 {
    let bounds = (cmap.size_x, cmap.size_y);
    let mut energized = Energized::new(cmap.size_x, cmap.size_y);
    let mut visited_cells: HashSet<Beam> = HashSet::new();
    let mut beams = vec![init_beam];

    while let Some(mut beam) = beams.pop() {
        while beam.is_inside(bounds) {
            if visited_cells.insert(beam.clone()) {
                energized.on(beam.x, beam.y);
            } else {
                break;
            }
            let obj = cmap.grid[beam.x][beam.y];
            match obj {
                '-' => {
                    if beam.dx != 0 {
                        beams.push(Beam::new((beam.x, beam.y, 0, !0)));
                        beam.dx = 0;
                        beam.dy = 1;
                    }
                }
                '|' => {
                    if beam.dy != 0 {
                        beams.push(Beam::new((beam.x, beam.y, !0, 0)));
                        beam.dx = 1;
                        beam.dy = 0;
                    }
                }
                '/' => beam.bounce(obj),
                '\\' => beam.bounce(obj),
                _ => (),
            }
            beam.next_step();
        }
    }
    energized.countup()
}

fn main() {
    let fname: String = env::args().nth(1).expect("no given filename");

    let data_it = match read_lines(&fname) {
        Err(error) => panic!("Problem reading the file {}: {:?}", fname, error),
        Ok(s) => s,
    };

    let contr_data = match parse_data(data_it) {
        Ok(hands) => hands,
        Err(error) => panic!("Problem parsing the file {}: {:?}", fname, error),
    };

    let contr = Cmap::new(contr_data);
    println!("Part one: {}", solve(&contr, Beam::new((0, 0, 0, 1))));

    let mut tpls: Vec<(usize, usize, usize, usize)> = Vec::new();
    for x in 0..contr.size_x {
        tpls.push((x, 0, 0, 1));
        tpls.push((x, contr.size_y - 1, 0, !0));
    }
    for y in 0..contr.size_y {
        tpls.push((0, y, 1, 0));
        tpls.push((contr.size_x - 1, y, !0, 0));
    }
    let max_value = tpls
        .iter()
        .map(|&tpl| Beam::new(tpl))
        .map(|beam| solve(&contr, beam))
        .max()
        .unwrap();
    println!("Part two: {}", max_value);
}
