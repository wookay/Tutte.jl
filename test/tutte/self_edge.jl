module test_tutte_self_edge

using Test
using Tutte.Graphs # WTEdge → ⇿

isselfedge(edge::WTEdge) = ==(edge.nodes...)

@test isselfedge(1 → 1)
@test !isselfedge(1 → 2)
@test isselfedge(1 ⇿ 1)
@test !isselfedge(1 ⇿ 2)

end # module test_tutte_self_edge
