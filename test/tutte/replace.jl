module test_tutte_replace

using Test
using Tutte.Graphs # Graph @nodes ⇿ →

@nodes A B C D E F

edges = A ⇿ C → D
@test replace(edges, D => F) == (A ⇿ C → F)
@test replace(edges, D => F, A => F) == (F ⇿ C → F)

graph = Graph(edges)
@test replace(graph, D => F) == Graph(A ⇿ C → F)
@test replace(graph, D => F, A => F) == Graph(F ⇿ C → F)

end # module test_tutte_replace
