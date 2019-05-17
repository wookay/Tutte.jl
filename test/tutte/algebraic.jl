module test_tutte_algebraic

using Test
using Tutte.Graphs # ⇿
using LinearAlgebra: Diagonal
using LightGraphs: SimpleGraph, adjacency_matrix, laplacian_matrix

# https://en.wikipedia.org/wiki/Laplacian_matrix

graph = Graph(union(1 ⇿ 2 ⇿ 3 ⇿ 4 ⇿ 5 ⇿ 1, 2 ⇿ 5, 4 ⇿ 6))
g = SimpleGraph(graph)

# degree_matrix
@test adjacency_matrix(g) + laplacian_matrix(g) == Diagonal([2, 3, 2, 3, 3, 1])

@test adjacency_matrix(g) == [0 1 0 0 1 0
                              1 0 1 0 1 0
                              0 1 0 1 0 0
                              0 0 1 0 1 1
                              1 1 0 1 0 0
                              0 0 0 1 0 0]

@test laplacian_matrix(g) == [ 2 -1  0  0 -1  0
                              -1  3 -1  0 -1  0
                               0 -1  2 -1  0  0
                               0  0 -1  3 -1 -1
                              -1 -1  0 -1  3  0
                               0  0  0 -1  0  1]

end # module test_tutte_algebraic
