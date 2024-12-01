viz_node(N) :- output_node(N), not node_end(N,_).
viz_node(N) :- output_node(N), node_end(N,_), output_edge(_,N,_).

viz_edge((N1,N2)) :- output_edge(N1,N2,D).

% GRAPH
viz_graph(default).
viz_attr(graph, default, name, "Flatland").
% GRAPH NODES
viz_attr(graph_nodes, default, shape, square).
viz_attr(graph_nodes, default, style, filled).
viz_attr(graph_nodes, default, fillcolor, white).
viz_attr(graph_nodes, default, width, "1").
viz_attr(graph_nodes, default, fontsize, 10).

dir_label(0, "N"). dir_label(1, "E"). dir_label(2, "S"). dir_label(3, "W").
dir_color(0, "#EF9A9A"). dir_color(1, "#A5D6A7"). dir_color(2, "#90CAF9"). dir_color(3, "#FFF59D").

viz_attr(edge, (N1,N2), label, D) :- viz_edge((N1,N2)), output_edge(N1,N2,D), D>0.

viz_attr(node, ((X,Y),DIR), label, LABEL) :- output_node(((X,Y),DIR)), dir_label(DIR,LABEL).
viz_attr(node, ((X,Y),0), pos, @pos(X*4+1,Y*4+1 -1)) :- output_node(((X,Y),0)).
viz_attr(node, ((X,Y),1), pos, @pos(X*4+1 +1,Y*4+1)) :- output_node(((X,Y),1)).
viz_attr(node, ((X,Y),2), pos, @pos(X*4+1,Y*4+1 +1)) :- output_node(((X,Y),2)).
viz_attr(node, ((X,Y),3), pos, @pos(X*4+1 -1,Y*4+1)) :- output_node(((X,Y),3)).

viz_attr(node, ((X,Y),DIR), shape, circle) :- output_node(((X,Y),DIR)).
viz_attr(node, ((X,Y),DIR), fillcolor, COLOR) :- output_node(((X,Y),DIR)), dir_color(DIR,COLOR).


% --- [ ROOT CELL NODES FOR DIRECTED NODES ] ---------------------------------------------------------------------------

viz_node((X,Y)) :- output_node(((X,Y),_)).

viz_edge(((X,Y),((X,Y),DIR))) :- viz_node((X,Y)), viz_node(((X,Y),DIR)).
viz_attr(edge, ((X,Y),((X,Y),DIR)), style, "dotted") :- viz_edge(((X,Y),((X,Y),DIR))).

% --- [ START AND END NODES ] ------------------------------------------------------------------------------------------

viz_attr(node, ((X,Y),DIR), penwidth, "4.0") :- node_start(((X,Y),DIR),_).
viz_attr(node, (X,Y), penwidth, "4.0") :- node_end(((X,Y),DIR),_).

viz_node((special,end,ID)) :- node_end(((X,Y),DIR),ID).
viz_node((special,start,ID)) :- node_start(((X,Y),DIR),ID).

viz_edge(((X,Y),(special,end,ID))) :- node_end(((X,Y),DIR),ID).
viz_edge((((X,Y),DIR),(special,start,ID))) :- node_start(((X,Y),DIR),ID).


viz_attr(node, (special,X,ID), label, ID) :- viz_node((special,X,ID)).
viz_attr(node, (special,X,ID), width, "0.5") :- viz_node((special,X,ID)).
viz_attr(node, (special,X,ID), shape, circle) :- viz_node((special,X,ID)).
viz_attr(node, (special,X,ID), penwidth, "4.0") :- viz_node((special,X,ID)).
