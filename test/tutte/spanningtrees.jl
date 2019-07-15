module test_tutte_spanningtrees

using Test
using Tutte.Graphs # WTGraph ⇿
using .Graphs: simplegraph_nodes
using LightGraphs: Edge, kruskal_mst, prim_mst

graph = WTGraph(union(1 ⇿ 2 ⇿ 3 ⇿ 4 ⇿ 5 ⇿ 1, 2 ⇿ 5, 4 ⇿ 6, 6 ⇿ 1, 6 ⇿ 2))
g, nodes = simplegraph_nodes(graph)
@test nodes == [1, 2, 3, 4, 5, 6]

distmx = [
0 1 1 1 1 1
1 0 1 1 1 1
1 1 0 1 1 1
1 1 1 0 1 1
1 1 1 1 0 1
1 1 1 1 1 0
]
@test kruskal_mst(g, distmx) == [Edge(1, 2), Edge(1, 5), Edge(1, 6), Edge(2, 3), Edge(3, 4)]
@test prim_mst(g, distmx)    == [Edge(1, 2), Edge(2, 3), Edge(6, 4), Edge(1, 5), Edge(1, 6)]

end # module test_tutte_spanningtrees
