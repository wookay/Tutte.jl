module test_tutte_graphs

using Test
using Tutte.Graphs # WTGraph WTEdges WTEdge WTNode @nodes ⇿ → ←  add_edges remove_edges add_edges! remove_edges!

G = WTGraph{WTNode}()
@nodes A B C D E F

@test isempty(G)
@test G isa WTGraph{WTNode}

@test (D ← C) isa WTEdge
@test (C → D) == (D ← C)
@test (A ⇿ C) == (C ⇿ A)
@test (A ⇿ C → D) == (D ← C ⇿ A)
@test F isa WTNode
@test union(C → D, D ← C) == WTEdges([C → D]) == WTEdges([D ← C])
@test union(C → D, D → C) == WTEdges([C → D, D → C]) == WTEdges([C → D, C ← D])
@test union(C → D, D → E, E ⇿ F) == WTEdges([C → D, D → E, E ⇿ F])
@test union(C → D, D → E → B) == WTEdges([C → D, D → E, E → B])
@test union(C → D, D → E → B, B → F) == WTEdges([C → D, D → E, E → B, B → F])

@nodes H
@test H isa WTNode
@test H == WTNode(:H)
@test H.id === :H

G = add_edges(G, A ⇿ C)
@test G.edges == WTEdges([A ⇿ C])
@test G.nodes == Set([A, C])
@test sprint(show, "text/plain", G) == "WTGraph{WTNode}(Set([A, C]), WTEdges{WTNode}([A ⇿ C]))"
@test !isempty(G)
@test length(G.edges) == 1

G2 = add_edges(G, A ⇿ C → D ← F)
@test G.edges == WTEdges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == WTEdges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])

G3 = remove_edges(G2, A ⇿ C)
@test G.edges == WTEdges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == WTEdges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])
@test G3.edges == WTEdges([C → D, D ← F])
@test G3.nodes == Set([A, C, D, F])

@test (1 ⇿ 2) isa WTEdge
@test (1 ⇿ 2 ⇿ 3) isa WTEdges

G = WTGraph{Int}()
G2 = add_edges(G, 1 ⇿ 3 → 4 ← 5)
@test G2.edges == WTEdges([1 ⇿ 3, 3 → 4, 4 ← 5])
@test G2.nodes == Set([1, 3, 4, 5])

@test (1 ⇄  2) == WTEdges([1 → 2, 1 ← 2])
@test (1 ⇆  2) == WTEdges([1 ← 2, 1 → 2])
@test (1 ⇆  2 ⇿ 3) == WTEdges([1 ← 2, 1 → 2, 2 ⇿ 3])

G = WTGraph{WTNode}()
add_edges!(G, A ⇿ C) do edges, nodes
    @test edges == [A ⇿ C]
    @test nodes == Set([A, C])
end
@test G.edges == WTEdges([A ⇿ C])
@test G.nodes == Set([A, C])
add_edges!(G, A ⇿ C → D ← F) do edges, nodes
    @test edges == [C → D, F → D]
    @test nodes == Set([D, F, C])
end
@test G.edges == WTEdges([A ⇿ C, C → D, D ← F])
@test G.nodes == Set([A, C, D, F])
remove_edges!(G, A ⇿ C) do edges, nodes
    @test edges == [A ⇿ C]
    @test nodes == Set([A, C])
end
@test G.edges == WTEdges([C → D, D ← F])
@test G.nodes == Set([A, C, D, F])

@test WTEdge(→, (1, 2), false) isa WTEdge{Int}
@test WTEdge{Int}(→, (1, 2), false) isa WTEdge{Int}

@test WTEdges([1 → 2]) isa WTEdges{Int}
@test WTEdges{Int}([1 → 2]) isa WTEdges{Int}

@test WTGraph(1 → 2) isa WTGraph{Int}
@test WTGraph{Int}(1 → 2) isa WTGraph{Int}
@test WTGraph(1 → 2 → 3) isa WTGraph{Int}
@test WTGraph{Int}(1 → 2 → 3) isa WTGraph{Int}

struct User
    name
    point
end
u1 = User("u1", 10)
u2 = User("u2", 5)
u3 = User("u3", 1)
g = WTGraph(u1 → u2 → u3)
@test g isa WTGraph{User}
@test sprint(show, "text/plain", g.edges) == """WTEdges{User}([User("u1", 10) → User("u2", 5), User("u2", 5) → User("u3", 1)])"""

@test (1 → 2) == (2 ← 1)
@test (1 → 2 → 3) == (3 ← 2 ← 1)
@test union(1 → 2, 1 → 2) == WTEdges([1 → 2])

end # module test_tutte_graphs
