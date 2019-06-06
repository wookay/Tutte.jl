module test_tutte_set

using Test
using Tutte.Graphs # @nodes WTGraph →

@nodes A B C D E

g = WTGraph(A → B → C)
@test A ∈ g.nodes
@test D ∉ g.nodes
@test 0 ∉ g.nodes
@test Set([A, B]) ⊆ g.nodes
@test Set([C, D]) ⊈ g.nodes
@test Set([0, 1]) ⊈ g.nodes

end # module test_tutte_set
