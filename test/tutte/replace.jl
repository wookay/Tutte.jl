module test_tutte_replace

using Test
using Tutte.Graphs # WTGraph @nodes ⇿ →

@nodes A B C D E F

edges = A ⇿ C → D
@test replace(edges, D => F) == (A ⇿ C → F)
@test replace(edges, D => F, A => F) == (F ⇿ C → F)

graph = WTGraph(edges)
@test replace(graph, D => F) == WTGraph(A ⇿ C → F)
@test replace(graph, D => F, A => F) == WTGraph(F ⇿ C → F)

end # module test_tutte_replace
