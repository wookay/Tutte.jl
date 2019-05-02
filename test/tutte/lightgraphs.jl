module test_tutte_lightgraphs

using Test
using Tutte.Graphs # ⇿ → ←  IDMap indexof
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, nv, ne, vertices, dfs_tree
using LightGraphs.SimpleGraphs: SimpleEdge, dfs_tree, bfs_tree, edges

r = SimpleGraph(1 ⇿ 3 ⇿ 4 ⇿ 5)
@test r isa SimpleGraph{Int}
@test (4, 3) == (nv(r), ne(r))
@test Graph(r) == Graph(1 ⇿ 2 ⇿ 3 ⇿ 4)
buf = IOBuffer()
Graphs.savegraph(buf, r)
@test String(take!(buf)) == "4,3,u,graph,2,Int64,simplegraph\n1,2\n2,3\n3,4\n"
buf = IOBuffer("4,3,u,graph,2,Int64,simplegraph\n1,2\n2,3\n3,4\n")
@test r == Graphs.loadgraph(buf)

r = SimpleDiGraph(1 → 3 → 4 ←  5)
@test r isa SimpleDiGraph{Int}
@test (4, 3) == (nv(r), ne(r))
@test Graph(r) == Graph(1 → 2 → 3 ←  4)
buf = IOBuffer()
Graphs.savegraph(buf, r)
@test String(take!(buf)) == "4,3,d,graph,2,Int64,simplegraph\n1,2\n2,3\n4,3\n"
buf = IOBuffer("4,3,d,graph,2,Int64,simplegraph\n1,2\n2,3\n4,3\n")
@test r == Graphs.loadgraph(buf)

@nodes A B C D E F
graph = Graph(union(A → C → D → E, C → E ← F))
idmap = IDMap(graph)
g = SimpleDiGraph(graph)
@test vertices(g) == Base.OneTo(5)

tree = dfs_tree(g, 1)
@test tree isa SimpleDiGraph{Int}
@test indexof(idmap, C) == 2


graph = Graph(union(1 → 3 → 4 → 5, 3 → 5 ← 6, 3 ← 2))
g = SimpleDiGraph(graph)
@test vertices(g) == Base.OneTo(6)

# Depth-first search
d = dfs_tree(g, 3)
@test collect(edges(d)) == [SimpleEdge(3, 4), SimpleEdge(4, 5)]

# Breadth-first search
b = bfs_tree(g, 3)
@test collect(edges(b)) == [SimpleEdge(3, 4), SimpleEdge(3, 5)]


graph = Graph(union(1 ⇿ 3 ⇿ 4 ⇿ 5, 3 ⇿ 5 ⇿ 6, 3 ⇿ 2))
g = SimpleGraph(graph)
@test vertices(g) == Base.OneTo(6)

# Depth-first search
d = dfs_tree(g, 3)
@test collect(edges(d)) == [SimpleEdge(3, 1), SimpleEdge(3, 2), SimpleEdge(3, 4), SimpleEdge(4, 5), SimpleEdge(5, 6)]

# Breadth-first search
b = bfs_tree(g, 3)
@test collect(edges(b)) == [SimpleEdge(3, 1), SimpleEdge(3, 2), SimpleEdge(3, 4), SimpleEdge(3, 5), SimpleEdge(5, 6)]

end # module test_tutte_lightgraphs
