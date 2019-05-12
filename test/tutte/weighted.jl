module test_tutte_weighted

using Test
using Tutte.Graphs # Weighted @nodes → ⇿

@nodes A B C D E F G

w1 = Weighted([A 5→ C 2→ F 1→ G], [A 3→ D 4→ F], [B 9→ D 8→ G], [B 6→ E 4→ G])
@test w1.graph.edges.list == [A → C, C → F, F → G, A → D, D → F, B → D, D → G, B → E, E → G]
@test w1.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]

w2 = Weighted([A 5⇿ C 2⇿ F 1⇿ G], [A 3⇿ D 4⇿ F], [B 9⇿ D 8⇿ G], [B 6⇿ E 4⇿ G])
@test w2.graph.edges.list == [A ⇿ C, C ⇿ F, F ⇿ G, A ⇿ D, D ⇿ F, B ⇿ D, D ⇿ G, B ⇿ E, E ⇿ G]
@test w2.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]

w3 = Weighted()
@test isempty(w3.graph)
@test isempty(w3.weights)

w4 = Weighted([A 1→ C], [A 2→ C])
@test w4.graph.edges.list == [A → C]
@test w4.weights == [3]

end # module test_tutte_weighted
