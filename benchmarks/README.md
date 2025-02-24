# Benchmarks

These benchmarks measure the time it takes the respective approaches to find one valid solution (plans for all the trains).

### Benchmark System Specs

+ Ubuntu 24.04
+ Intel Core i5 13600k
+ 64GiB DDR5 6000MT/s RAM
+ clingo 5.7.1

### Results

| benchmark                                           | `x` | `y` | `s` | `t` | `h` | [base encoding](../encodings/rail_new_actions.lp) | flatgraph |     speedup |
|:----------------------------------------------------|-----|-----|-----|-----|-----|:--------------------------------------------------|-----------|------------:|
| [circle](./circle.lp)                               | 10  | 10  | 0   | 36  |     |                                                   |           |             |
| [crossing](./crossing.lp)                           | 3   | 3   | 1   | 5   | 10  | `0.010s`                                          | `0.0045s` |   `2.22` 🔼 |
| [crossing_distractions](./crossing_distractions.lp) | 19  | 19  | 161 | 329 | 30  | `4.415s`                                          | `0.1620s` |  `27.25` 🔼 |
| [crossing_grid](./crossing_grid.lp)                 | 19  | 19  | 1   | 361 | 30  | `0.089s`                                          | `0.1774s` |   `0.50` 🔻 |
| [crossing_large](./crossing_large.lp)               | 19  | 19  | 1   | 37  | 30  | `0.068s`                                          | `0.0188s` |   `3.62` 🔼 |
| [detour](./detour.lp)                               | 16  | 16  | 2   | 254 | 100 | `2.647s`                                          | `0.0912s` | `29.02`  🔼 |
| [congestion](./congestion.lp)                       | 15  | 15  | -   | -   | 100 | -                                                 | BROKEN    |           - |

Legend:
+ `x`: map width
+ `y`: map height
+ `s`: number of switches
+ `t`: number of total tracks (switches included)
+ `h`: time horizon

## Help

Computing Track-Count `t` :

```bash
cho "count(C) :- C=#count{1,X,Y: cell((X,Y),T), T>0}. #show count/1." | clingo - <INSTANCE>
```