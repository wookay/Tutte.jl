module test_tutte_lightgraphs

using Test
using Tutte.Graphs # ⇿ → ←
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, nv, ne

r = SimpleGraph(1 ⇿ 3 ⇿ 4 ⇿ 5)
@test r isa SimpleGraph{Int}
@test (4, 3) == (nv(r), ne(r))

r = SimpleDiGraph(1 → 3 → 4 ←  5)
@test r isa SimpleDiGraph{Int}
@test (4, 3) == (nv(r), ne(r))

end # module test_tutte_lightgraphs
