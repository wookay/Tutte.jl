module test_tutte_graphs

using Test
using Tutte.Graphs # Graph Edge Edges Node @nodes ⇿ → ←  addedges cutedges

G = Graph()
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

G = addedges(G, A ⇿ C)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test !isempty(G)

G2 = addedges(G, A ⇿ C → D ← F)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == Edges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])

G3 = cutedges(G2, A ⇿ C)
@test G.edges == Edges([A ⇿ C])
@test G.nodes == Set([A, C])
@test G2.edges == Edges([A ⇿ C, C → D, D ← F])
@test G2.nodes == Set([A, C, D, F])
@test G3.edges == Edges([C → D, D ← F])
@test G3.nodes == Set([A, C, D, F])

@test (1 ⇿ 2) isa Edge
@test (1 ⇿ 2 ⇿ 3) isa Edges

G = Graph()
G2 = addedges(G, 1 ⇿ 3 → 4 ← 5)
@test G2.edges == Edges([1 ⇿ 3, 3 → 4, 4 ← 5])
@test G2.nodes == Set([1, 3, 4, 5])

@test (1 ⇄  2) == Edges([1 → 2, 1 ← 2])
@test (1 ⇆  2) == Edges([1 ← 2, 1 → 2])
@test (1 ⇆  2 ⇿ 3) == Edges([1 ← 2, 1 → 2, 2 ⇿ 3])

end # module test_tutte_graphs
