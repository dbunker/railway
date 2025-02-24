# Benchmarks

These benchmarks measure the time it takes the respective approaches to find one valid solution (plans for all the trains).

### Benchmark System Specs

+ Ubuntu 24.04
+ Intel Core i5 13600k
+ 64GiB DDR5 6000MT/s RAM
+ clingo 5.7.1

### Results

| benchmark                                           | [simple encoding](../encodings/rail_new_actions.lp) | flatgraph |     speedup |
|:----------------------------------------------------|:----------------------------------------------------|-----------|------------:|
| [circle](./circle.lp)                               |                                                     |           |             |
| [crossing](./crossing.lp)                           | `0.010s`                                            | `0.0045s` |   `2.22` 🔼 |
| [crossing_distractions](./crossing_distractions.lp) | `4.415s`                                            | `0.1620s` |  `27.25` 🔼 |
| [crossing_grid](./crossing_grid.lp)                 | `0.089s`                                            | `0.1774s` |   `0.50` 🔻 |
| [crossing_large](./crossing_large.lp)               | `0.068s`                                            | `0.0188s` |   `3.62` 🔼 |
| [detour](./detour.lp)                               | `2.647s`                                            | `0.0912s` | `29.02`  🔼 |