
node(POS) :- edge(POS, _).
node(POS) :- edge(_, POS).

edge((POS_A, POS_B)) :- edge(POS_A, POS_B).

edge((POS_A, POS_B, 1)) :- edge(POS_A, POS_B), move(a, POS_A, POS_B).

attr(edge, (POS_A, POS_B, 1), color, "green") :- edge(POS_A, POS_B), move(a, POS_A, POS_B).

attr(graph_nodes, default, style, filled).

attr(node, POS, color, "#b2acfc") :- start(a, POS, _).
attr(node, POS, color, "#7e73ff") :- at(a, POS), not start(a, POS, _), not end(a, POS, _).
attr(node, POS, color, "#1500ff") :- end(a, POS, _).

