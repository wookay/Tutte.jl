module test_tutte_weighted

using Test
using Tutte.Graphs # Weighted WTNode @nodes → ← ⇿ ⇄  ⇆

@nodes A B C D E F G

w1 = Weighted([A 5→ C 2→ F 1→ G], [A 3→ D 4→ F], [B 9→ D 8→ G], [B 6→ E 4→ G])
@test w1.graph.edges.list == [A → C, C → F, F → G, A → D, D → F, B → D, D → G, B → E, E → G]
@test w1.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]

w2 = Weighted([A 5⇿ C 2⇿ F 1⇿ G], [A 3⇿ D 4⇿ F], [B 9⇿ D 8⇿ G], [B 6⇿ E 4⇿ G])
@test w2.graph.edges.list == [A ⇿ C, C ⇿ F, F ⇿ G, A ⇿ D, D ⇿ F, B ⇿ D, D ⇿ G, B ⇿ E, E ⇿ G]
@test w2.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]

w3 = Weighted{WTNode, Int}()
@test isempty(w3)
@test isempty(w3.graph)
@test isempty(w3.weights)
@test !Graphs.is_directed(w3)

w4 = Weighted([A 1→ C], [A 2→ C])
@test w4.graph.edges.list == [A → C]
@test w4.weights == [3]

w5 = Weighted([A 1⇄  C])
@test w5.graph.edges.list == [A → C, A ←  C]
@test w5.weights == [1, 1]

w6 = Weighted([A 1⇄  C 2⇄  D])
@test w6.graph.edges.list == [A → C, A ←  C, C → D, C ← D]
@test w6.weights == [1, 1, 2, 2]

w7 = Weighted([A 1⇆  C 2⇆  D 3→ E 4⇄  F 5⇄  G], [D 6→ E])
@test w7.graph.edges.list == [A ← C, A → C, C ← D, C → D, D → E, E → F, E ← F, F → G, F ← G]
@test w7.weights == [1, 1, 2, 2, 9, 4, 4, 5, 5]

w8 = Weighted([A 1⇿ C])
@test w8.graph.edges.list == [A ⇿ C]
@test w8.weights == [1]

w9 = Weighted([1 -1→ 2])
@test w9.graph.edges.list == [1 → 2]
@test w9.weights == [-1]
@test w9 isa Weighted{Int, Int}
add_edges!(w9, [1 6→ 2 7→ 3]) do edges, weights, nodes
    @test edges == [1 → 2, 2 → 3]
    @test weights == [5, 7]
    @test nodes == Set([1, 2, 3])
end
@test w9.graph.edges.list == [1 → 2, 2 → 3]
@test w9.weights == [5, 7]
remove_edges!(w9, 1 → 2) do edges, weights, nodes
    @test edges == [1 → 2]
    @test weights == [5]
    @test nodes == Set([1, 2])
end
@test w9.graph.edges.list == [2 → 3]
@test w9.weights == [7]
@test Graphs.is_directed(w9)

@test Weighted([1 1⇿ 2]) isa Weighted{Int, Int}
@test Weighted{Int, Int}([1 1⇿ 2]) isa Weighted{Int, Int}

w10 = Weighted([1 5im⇿ 2])
@test w10.graph.edges.list == [1 ⇿ 2]
@test w10.weights == [5im]
@test !Graphs.is_directed(w10)

struct Weight
    value
end
Base.:+(a::Weight, b::Weight) = Weight(a.value + b.value)
Base.:+(w::Weight, n::Int) = Weight(w.value + n)
w11 = Weighted([1 Weight(5)⇿ 2], [1 Weight(-2)⇿ 2])
@test w11 isa Weighted{Int, Weight}
@test w11.graph.edges.list == [1 ⇿ 2]
@test w11.weights == [Weight(3)]
@test sprint(show, "text/plain", w11) == "Weighted{Int64, Weight}(WTGraph{Int64}(Set([2, 1]), WTEdges{Int64}([1 ⇿ 2])), [Weight(3)])"

end # module test_tutte_weighted
