module test_tutte_custom_edge

using Test
using Tutte.Graphs # WTEdges WTEdge

function ↪(a::T, b::T)::WTEdge{T} where T
    WTEdge{T}(↪, (a, b), false)
end
function ↩(a::T, b::T)::WTEdge{T} where T
    WTEdge{T}(↪, (b, a), true)
end
Graphs.is_directed(::typeof(↪)) = true
Graphs.is_directed(::typeof(↩)) = true
Graphs.inverse(::typeof(↪)) = ↩
Graphs.inverse(::typeof(↩)) = ↪
for arrow in (:↪ , :↩ )
    @eval function ($arrow)(a::T, edges::WTEdges{T})::WTEdges where T
        edge = first(edges.list)
        WTEdges([$arrow(a, Graphs.nodeof(edge, first)), edges.list...])
    end
    @eval function ($arrow)(a::T, edge::WTEdge{T})::WTEdges where T
        WTEdges([$arrow(a, Graphs.nodeof(edge, first)), edge])
    end
    @eval function ($arrow)(edge::WTEdge{T}, b::T)::WTEdges where T
        WTEdges([edge, $arrow(WTGraphs.nodeof(edge, last), b)])
    end
end

@test (1 ↪ 2) == (2 ↩ 1)
@test (1 ↪ 2 ↪ 3) == (3 ↩ 2 ↩ 1)
@test union(1 ↪ 2, 1 ↪ 2) == WTEdges([1 ↪ 2])
@test (1 ↪ 2) isa WTEdge{Int}
@test union(1 → 2, 1 ↪ 2) == WTEdges([1 → 2, 1 ↪ 2])
@test Graphs.is_directed(union(1 → 2, 1 ↪ 2))

# Weighted
function ↪(a::A, b::B)::WTEdge{Union{A,B}} where {A, B}
    WTEdge{Union{A,B}}(↪, (a, b), false)
end
function ↩(a::A, b::B)::WTEdge{Union{A, B}} where {A, B}
    WTEdge{Union{A,B}}(↩, (b, a), true)
end

@nodes A B C D
w = Weighted([A 3↪ B 5↪ C])
@test w.graph.edges.list == [A ↪ B, B↪ C]
@test w.weights == [3, 5]
@test sprint(show, "text/plain", w) == "Weighted{WTNode, Int64}(WTGraph{WTNode}(Set([A, B, C]), WTEdges{WTNode}([A ↪ B, B ↪ C])), [3, 5])"

add_edges!(w, [A -1↪ B 1↪ D]) do edges, weights, nodes
    @test edges == [A ↪  B, B ↪  D]
    @test weights == [2, 1]
    @test nodes == Set([A, B, D])
end
@test w.graph.edges.list == [A ↪ B, B↪ C, B ↪  D]
@test w.weights == [2, 5, 1]

remove_edges!(w, A ↪ B) do edges, weights, nodes
    @test edges == [A ↪ B]
    @test weights == [2]
    @test nodes == Set([A, B])
end
@test w.graph.edges.list == [B↪ C, B ↪  D]
@test w.weights == [5, 1]

end # module test_tutte_custom_edge
