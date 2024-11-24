#!/bin/bash
clingo encodings/common.lp encodings/track_type_decoding.lp $1 graph/create_directed_graph.lp --outf=2 |
clingraph --view --out=render --prefix=viz_ --viz-encoding=graph/viz.lp --type=digraph