module test_tutte_custom_edge

using Test
using Tutte.Graphs

function ↪(a::T, b::T)::Edge{T} where T
    Edge{T}(↪, (a, b), false)
end
function ↩(a::T, b::T)::Edge{T} where T
    Edge{T}(↪, (b, a), true)
end
Graphs.is_directed(::typeof(↪)) = true
Graphs.is_directed(::typeof(↩)) = true
Graphs.inverse(::typeof(↪)) = ↩
for arrow in (:↪ , :↩ )
    @eval function ($arrow)(a::T, edges::Edges{T})::Edges where T
        edge = first(edges.list)
        Edges([$arrow(a, Graphs.nodeof(edge, first)), edges.list...])
    end
    @eval function ($arrow)(a::T, edge::Edge{T})::Edges where T
        Edges([$arrow(a, Graphs.nodeof(edge, first)), edge])
    end
    @eval function ($arrow)(edge::Edge{T}, b::T)::Edges where T
        Edges([edge, $arrow(Graphs.nodeof(edge, last), b)])
    end
end

@test (1 ↪ 2) == (2 ↩ 1)
@test (1 ↪ 2 ↪ 3) == (3 ↩ 2 ↩ 1)
@test union(1 ↪ 2, 1 ↪ 2) == Edges([1 ↪ 2])
@test (1 ↪ 2) isa Edge{Int}
@test union(1 → 2, 1 ↪ 2) == Edges([1 → 2, 1 ↪ 2])
@test Graphs.is_directed(union(1 → 2, 1 ↪ 2))

# Weighted
function ↪(a::A, b::B)::Edge{Union{A,B}} where {A, B}
    Edge{Union{A,B}}(↪, (a, b), false)
end
function ↩(a::A, b::B)::Edge{Union{A, B}} where {A, B}
    Edge{Union{A,B}}(↩, (b, a), true)
end

@nodes A B C D
w = Weighted([A 3↪ B 5↪ C])
@test w.graph.edges.list == [A ↪ B, B↪ C]
@test w.weights == [3, 5]
@test sprint(show, "text/plain", w) == "Weighted{Node, Int64}(Graph{Node}(Set([A, B, C]), Edges{Node}([A ↪ B, B ↪ C])), [3, 5])"

addedges!(w, [A -1↪ B 1↪ D]) do edges, weights, nodes
    @test edges == [A ↪  B, B ↪  D]
    @test weights == [2, 1]
    @test nodes == Set([A, B, D])
end
@test w.graph.edges.list == [A ↪ B, B↪ C, B ↪  D]
@test w.weights == [2, 5, 1]

cutedges!(w, A ↪ B) do edges, weights, nodes
    @test edges == [A ↪ B]
    @test weights == [2]
    @test nodes == Set([A, B])
end
@test w.graph.edges.list == [B↪ C, B ↪  D]
@test w.weights == [5, 1]

end # module test_tutte_custom_edge
