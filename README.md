# Railway Scheduling Project

Project for the course "Railway Scheduling" for the M.Sc. Program Cognitive Systems of University of Potsdam

This Project uses the [KRR-Flatland](https://github.com/krr-up/flatland) repo for ASP.

+ Using the Flatland environment:
  + Project: https://flatland.aicrowd.com/intro.html
  + Paper: https://arxiv.org/pdf/2012.05893
  + Docs: https://flatland.aicrowd.com/intro.html

## Installation

Install the prerequisite packages using `pip`

```bash
pip install -r requirements.txt
pip install -e .
```

## Flatgraph Usage

```
flatgraph benchmarks/crossing.lp -t
```

+ This will run the ordering encoding on `benchmarks/crossing.lp` and return the actions.

## Benchmark Generation

```
flatgraph 0 -g
```

+ This generates random Flatland environments associated with sparse and dence environments with few and many trains and puts them into [benchmarks](./generated_benchmarks).

```
flatgraph 0 -r
```

+ This runs and gets statistics for all [generated benchmarks](./generated_benchmarks) using the baseline encoding and puts them into [solutions](./generated_benchmarks/solutions). Also runs the ordering encoding and puts them into [order_solutions](./generated_benchmarks/order_solutions).

```
flatgraph 0 -s
```

+ This aggregates the statistics from [generated benchmarks](./generated_benchmarks).

## Visualization

```
flatgraph 0 -v
```

+ This generates and solves a randomly generated Flatland environment.

```
flatgraph 0 -v -p benchmarks/crossing.lp
```

+ This visualizes and solves for the provided instance, converting it to a Flatland environment.

## Benchmarks

+ Benchmarks and their results can be found in [benchmarks](./benchmarks) and [benchmarks](./generated_benchmarks)

## Environment

### Track-Types

![All possible different track types](https://imgur.com/Q72tAI8.png)
