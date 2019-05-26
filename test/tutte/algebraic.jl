using Jive
@useinside module test_tutte_algebraic

using Test
using Tutte.Graphs # Graph ⇿
using Tutte.Graphs: simplegraph_nodes
using LinearAlgebra: Diagonal
using LightGraphs: SimpleGraph, adjacency_matrix, laplacian_matrix

# https://en.wikipedia.org/wiki/Laplacian_matrix

graph = Graph(union(1 ⇿ 2 ⇿ 3 ⇿ 4 ⇿ 5 ⇿ 1, 2 ⇿ 5, 4 ⇿ 6))
g, nodes = simplegraph_nodes(graph)
adj = adjacency_matrix(g)
lap = laplacian_matrix(g)

# degree_matrix
@test adj + lap == Diagonal([2, 3, 2, 3, 3, 1])

@test adj == [0 1 0 0 1 0
              1 0 1 0 1 0
              0 1 0 1 0 0
              0 0 1 0 1 1
              1 1 0 1 0 0
              0 0 0 1 0 0]

@test lap == [ 2 -1  0  0 -1  0
              -1  3 -1  0 -1  0
               0 -1  2 -1  0  0
               0  0 -1  3 -1 -1
              -1 -1  0 -1  3  0
               0  0  0 -1  0  1]

@test graph == Graph(SimpleGraph(adj))

end # module test_tutte_algebraic
