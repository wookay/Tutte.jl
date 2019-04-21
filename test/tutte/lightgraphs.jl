module test_tutte_lightgraphs

using Test
using Tutte.Graphs # ⇿ → ←
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, nv, ne

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

end # module test_tutte_lightgraphs
