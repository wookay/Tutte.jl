module test_tutte_graphs

using Test
using Tutte.Graphs # Graph Edge Edges Node @nodes ⇿ → ←  add_edges remove_edges add_edges! remove_edges!

G = Graph{Node}()
@nodes A B C D E F

@test isempty(G)
@test G isa Graph

@test (D ← C) isa Edge
@test (C → D) == (D ← C)
@test (A ⇿ C) == (C ⇿ A)
@test (A ⇿ C → D) == (D ← C ⇿ A)
@test F isa Node
@test union(C → D, D ← C) == Edges([C → D]) == Edges([D ← C])
@test union(C → D, D → C) == Edges([C → D, D → C]) == Edges([C → D, C ← D])
@test union(C → D, D → E, E ⇿ F) == Edges([C → D, D → E, E ⇿ F])
@test union(C → D, D → E → B) == Edges([C → D, D → E, E → B])
@test union(C → D, D → E → B, B → F) == Edges([C → D, D → E, E → B, B → F])

@nodes H
@test H isa Node
@test H == Node(:H)
@test H.id === :H

G = add_edges(G, A ⇿ C)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test sprint(show, "text/plain", G) == "Graph{Node}(Set([A, C]), Edges{Node}([A ⇿ C]))"
@test !isempty(G)
@test length(G.edges) == 1

G2 = add_edges(G, A ⇿ C → D ← F)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == Edges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])

G3 = remove_edges(G2, A ⇿ C)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == Edges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])
@test G3.edges == Edges([C → D, D ← F])
@test G3.nodes == Set([A, C, D, F])

@test (1 ⇿ 2) isa Edge
@test (1 ⇿ 2 ⇿ 3) isa Edges

G = Graph{Int}()
G2 = add_edges(G, 1 ⇿ 3 → 4 ← 5)
@test G2.edges == Edges([1 ⇿ 3, 3 → 4, 4 ← 5])
@test G2.nodes == Set([1, 3, 4, 5])

@test (1 ⇄  2) == Edges([1 → 2, 1 ← 2])
@test (1 ⇆  2) == Edges([1 ← 2, 1 → 2])
@test (1 ⇆  2 ⇿ 3) == Edges([1 ← 2, 1 → 2, 2 ⇿ 3])

G = Graph{Node}()
add_edges!(G, A ⇿ C) do edges, nodes
    @test edges == [A ⇿ C]
    @test nodes == Set([A, C])
end
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
add_edges!(G, A ⇿ C → D ← F) do edges, nodes
    @test edges == [C → D, F → D]
    @test nodes == Set([D, F, C])
end
@test G.edges == Edges([A ⇿ C, C → D, D ← F])
@test G.nodes == Set([A, C, D, F])
remove_edges!(G, A ⇿ C) do edges, nodes
    @test edges == [A ⇿ C]
    @test nodes == Set([A, C])
end
@test G.edges == Edges([C → D, D ← F])
@test G.nodes == Set([A, C, D, F])

@test Edge(→, (1, 2), false) isa Edge{Int}
@test Edge{Int}(→, (1, 2), false) isa Edge{Int}

@test Edges([1 → 2]) isa Edges{Int}
@test Edges{Int}([1 → 2]) isa Edges{Int}

@test Graph(1 → 2) isa Graph{Int}
@test Graph{Int}(1 → 2) isa Graph{Int}
@test Graph(1 → 2 → 3) isa Graph{Int}
@test Graph{Int}(1 → 2 → 3) isa Graph{Int}

struct User
    name
    point
end
u1 = User("u1", 10)
u2 = User("u2", 5)
u3 = User("u3", 1)
g = Graph(u1 → u2 → u3)
@test g isa Graph{User}
@test sprint(show, "text/plain", g.edges) == """Edges{User}([User("u1", 10) → User("u2", 5), User("u2", 5) → User("u3", 1)])"""

@test (1 → 2) == (2 ← 1)
@test (1 → 2 → 3) == (3 ← 2 ← 1)
@test union(1 → 2, 1 → 2) == Edges([1 → 2])

end # module test_tutte_graphs
