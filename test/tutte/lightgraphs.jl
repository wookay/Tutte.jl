module test_tutte_lightgraphs

using Test
using Tutte.Graphs # WTGraph ⇿ → ←
using Tutte.Graphs: simplegraph_nodes, simpledigraph_nodes
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, SimpleEdge, nv, ne, vertices, edges, dfs_tree, bfs_tree

r, nodes = simplegraph_nodes(1 ⇿ 3 ⇿ 4 ⇿ 5)
@test r isa SimpleGraph{Int}
@test nodes == [1, 3, 4, 5]
@test (4, 3) == (nv(r), ne(r))
@test WTGraph(r, nodes) == WTGraph(1 ⇿ 3 ⇿ 4 ⇿ 5)
@test WTGraph(r) == WTGraph(1 ⇿ 2 ⇿ 3 ⇿ 4)
buf = IOBuffer()
Graphs.savegraph(buf, r)
@test String(take!(buf)) == "4,3,u,graph,2,Int64,simplegraph\n1,2\n2,3\n3,4\n"
buf = IOBuffer("4,3,u,graph,2,Int64,simplegraph\n1,2\n2,3\n3,4\n")
@test r == Graphs.loadgraph(buf)

r, nodes = simpledigraph_nodes(1 → 3 → 4 ←  5)
@test r isa SimpleDiGraph{Int}
@test (4, 3) == (nv(r), ne(r))
@test WTGraph(r) == WTGraph(1 → 2 → 3 ←  4)
buf = IOBuffer()
Graphs.savegraph(buf, r)
@test String(take!(buf)) == "4,3,d,graph,2,Int64,simplegraph\n1,2\n2,3\n4,3\n"
buf = IOBuffer("4,3,d,graph,2,Int64,simplegraph\n1,2\n2,3\n4,3\n")
@test r == Graphs.loadgraph(buf)

@nodes A B C D E F
graph = WTGraph(union(A → C → D → E, C → E ← F))
g, nodes = simpledigraph_nodes(graph)
@test vertices(g) == Base.OneTo(5)

tree = dfs_tree(g, 1)
@test tree isa SimpleDiGraph{Int}
@test findfirst(==(C), nodes) == 2

graph = WTGraph(union(1 → 3 → 4 → 5, 3 → 5 ← 6, 3 ← 2))
g, nodes = simpledigraph_nodes(graph)
@test vertices(g) == Base.OneTo(6)

# Depth-first search
d = dfs_tree(g, 3)
@test d isa SimpleDiGraph
@test collect(edges(d)) == [SimpleEdge(3, 4), SimpleEdge(4, 5)]

# Breadth-first search
b = bfs_tree(g, 3)
@test b isa SimpleDiGraph
@test collect(edges(b)) == [SimpleEdge(3, 4), SimpleEdge(3, 5)]


graph = WTGraph(union(1 ⇿ 3 ⇿ 4 ⇿ 5, 3 ⇿ 5 ⇿ 6, 3 ⇿ 2))
g, nodes = simplegraph_nodes(graph)
@test vertices(g) == Base.OneTo(6)

# Depth-first search
d = dfs_tree(g, 3)
@test d isa SimpleDiGraph
@test collect(edges(d)) == [SimpleEdge(3, 1), SimpleEdge(3, 2), SimpleEdge(3, 4), SimpleEdge(4, 5), SimpleEdge(5, 6)]

# Breadth-first search
b = bfs_tree(g, 3)
@test b isa SimpleDiGraph
@test collect(edges(b)) == [SimpleEdge(3, 1), SimpleEdge(3, 2), SimpleEdge(3, 4), SimpleEdge(3, 5), SimpleEdge(5, 6)]

end # module test_tutte_lightgraphs
