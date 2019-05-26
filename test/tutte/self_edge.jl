module test_tutte_self_edge

using Test
using Tutte.Graphs # Edge → ⇿

isselfedge(edge::Edge) = ==(edge.nodes...)

@test isselfedge(1 → 1)
@test !isselfedge(1 → 2)
@test isselfedge(1 ⇿ 1)
@test !isselfedge(1 ⇿ 2)

end # module test_tutte_self_edge
