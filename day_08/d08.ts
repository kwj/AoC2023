/* Day 8 */

interface CycleInfo {
  lam: number;
  mu: number;
  ends: number[];
}

class Navigator {
  instr: number[];
  instr_len: number;
  next_map: Map<string, string[]>;

  constructor(data: string) {
    const [header, mapping] = data.split(/\n\n/);

    this.instr = header.split("").map((dir) => dir === "L" ? 0 : 1);
    this.instr_len = this.instr.length;

    const tbl = new Map<string, string[]>();
    for (const line of mapping.trim().split(/\n/)) {
      const [c, l, r] = line.split(/[^0-9A-Z]+/);
        tbl.set(c, [l, r]);
    }
    this.next_map = tbl;
  }

  get_steps(start: string, target: string): number {
    let steps = 0;
    let idx = 0;
    let crnt = start;
    while (crnt !== target) {
      crnt = this.next_map.get(crnt)![this.instr[idx]];
      steps += 1;
      idx = steps % this.instr_len;
    }

    return steps;
  }

  /*
    Brent's algorithm for cycle detection
    https://en.wikipedia.org/wiki/Cycle_detection#Brent's_algorithm
  */
  get_cycle_info(start: string): CycleInfo {
    let power = 1;
    let lam = 1;
    let t_idx = 0;
    let h_idx = 0;
    let ends: number[] = [];

    let tortoise = start;
    let hare = this.next_map.get(start)![this.instr[h_idx % this.instr_len]];
    h_idx += 1;
    while (tortoise !== hare || t_idx % this.instr_len !== h_idx % this.instr_len) {
      if (hare.endsWith("Z") === true) {
        ends.push(h_idx);
      }
      if (power === lam) {
        tortoise = hare;
	t_idx = h_idx;
	power *= 2;
	lam = 0;
      }
      hare = this.next_map.get(hare)![this.instr[h_idx % this.instr_len]];
      h_idx += 1;
      lam += 1;
    }

    tortoise = start;
    hare = start;
    for (h_idx = 0; h_idx < lam; h_idx++) {
      hare = this.next_map.get(hare)![this.instr[h_idx % this.instr_len]];
    }
    t_idx = 0;
    while (tortoise !== hare || t_idx % this.instr_len !== h_idx % this.instr_len) {
      tortoise = this.next_map.get(tortoise)![this.instr[t_idx % this.instr_len]];
      t_idx += 1;
      hare = this.next_map.get(hare)![this.instr[h_idx % this.instr_len]];
      h_idx += 1;
    }

    return {lam: lam, mu: t_idx, ends: ends};
  }
}

function gcd(x: number, y: number): number {
  if (y === 0) {
    return x;
  } else {
    return gcd(y, x % y);
  }
}

function lcm(x: number, y: number): number {
  return (x / gcd(x, y)) * y;
}

function part_one(nav: Navigator): void {
  console.log(nav.get_steps("AAA", "ZZZ"));
}

function part_two(nav: Navigator): void {
  const start_nodes = [...nav.next_map.keys()].filter((word) => word.endsWith("A"));
  const cycle_info = start_nodes.map((node) => nav.get_cycle_info(node));

  if (cycle_info.every((info) => info.lam === info.ends[0]) === true) {
    // Check if either each cycle length is equal to the distance from the starting node
    // to the last node whose name ends `Z`. If so, calculate the LCM of all length of cycles.
    console.log(cycle_info.reduce((acc, info) => lcm(acc, info.lam), 1));
  } else {
    // In other cases, I think the Chinese remainder theorem could be used
    // to solve the problem, but I give up for now.
    console.log("This input data can't be solved by this solver.");
    console.log("[cycle information]");
    console.log(cycle_info);
  }
}

// main - entry point
if (Deno.args.length === 2) {
  const data = await fetch(new URL(Deno.args[1], import.meta.url));
  const nav = new Navigator(await data.text());

  switch (Deno.args[0]) {
    case "1":
      part_one(nav);
      break;
    case "2":
      part_two(nav);
      break;
    default:
      console.log("Parameter error: invlaid `part` number");
  }
}
