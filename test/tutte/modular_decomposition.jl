using Jive
@useinside module test_tutte_modular_decomposition

using Test
using Tutte.Graphs # WTGraph ⇿ @nodes
using Tutte.Graphs: simplegraph_nodes
using LightGraphs: SimpleGraph, adjacency_matrix
using GraphModularDecomposition: StrongModuleTree, sparse

graph = WTGraph(union(1 ⇿ 2 ⇿ 3 ⇿ 4 ⇿ 5 ⇿ 1, 2 ⇿ 5, 4 ⇿ 6, 6 ⇿ 1, 6 ⇿ 2))
g, nodes = simplegraph_nodes(graph)
@test nodes == [1, 2, 3, 4, 5, 6]
adj = adjacency_matrix(g)
tree = StrongModuleTree(adj)
@test repr(sort!(tree)) == "{1 2 3 4 (5 6)}"

@nodes A B C D E F
graph = WTGraph(union(A ⇿ B ⇿ C ⇿ D ⇿ E ⇿ A, B ⇿ E, D ⇿ F, F ⇿ A, F ⇿ B))
g, nodes = simplegraph_nodes(graph)
@test nodes == [A, B, C, D, E, F]
adj = adjacency_matrix(g)
tree = StrongModuleTree(adj)
# prime 5-node (6-leaf) module: 1
@test repr(sort!(tree)) == "{1 2 3 4 (5 6)}"

# directed graph example [Capelle, Habib & Montgolfier 2002]
G = sparse(
    [1, 1, 1, 2, 3, 3, 3, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 8, 8, 10, 10,
     10, 10, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14],
    [3, 4, 5, 1, 2, 4, 5, 2, 4, 2, 7, 8, 9, 10, 8, 9, 10, 9, 10, 11,
     12, 13, 14, 9, 10, 14, 9, 10, 11, 13, 9, 10, 11, 12, 9, 10, 11],
    1
)
T = sort!(StrongModuleTree(G))

# 0-complete 2-node (14-leaf) module: 1
@test repr(T) == "({1 2 [3 4 5]} {[6 7 8] 9 10 {11 (12 13) 14}})"

# kind
# :prime {}
# :linear []
# :complete ()

end # module test_tutte_modular_decomposition
