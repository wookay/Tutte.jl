module test_tutte_modular_decomposition

using Test
using Tutte.Graphs # Graph ⇿ @nodes
using Tutte.Graphs: simplegraph_nodes
using LightGraphs: SimpleGraph, adjacency_matrix
using GraphModularDecomposition: StrongModuleTree

graph = Graph(union(1 ⇿ 2 ⇿ 3 ⇿ 4 ⇿ 5 ⇿ 1, 2 ⇿ 5, 4 ⇿ 6, 6 ⇿ 1, 6 ⇿ 2))
g, nodes = simplegraph_nodes(graph)
@test nodes == [1, 2, 3, 4, 5, 6]
adj = adjacency_matrix(g)
tree = StrongModuleTree(adj)
@test repr(sort!(tree)) == "{1 2 3 4 (5 6)}"

@nodes A B C D E F
graph = Graph(union(A ⇿ B ⇿ C ⇿ D ⇿ E ⇿ A, B ⇿ E, D ⇿ F, F ⇿ A, F ⇿ B))
g, nodes = simplegraph_nodes(graph)
@test nodes == [A, B, C, D, E, F]
adj = adjacency_matrix(g)
tree = StrongModuleTree(adj)
@test repr(sort!(tree)) == "{1 2 3 4 (5 6)}"

end # module test_tutte_modular_decomposition
