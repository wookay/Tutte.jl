# Tutte ፨

```julia
using Tutte.Graphs # @nodes Graph Weighted →
@nodes A B C D E F G
g = Graph(union(A → C → F → G, A → D → F, B → D → G, B → E → G))
w = Weighted([A 5→ C 2→ F 1→ G], [A 3→ D 4→ F], [B 9→ D 8→ G], [B 6→ E 4→ G])
w.graph == g
w.graph.edges.list == [A → C, C → F, F → G, A → D, D → F, B → D, D → G, B → E, E → G]
w.graph.nodes == Set([A, B, C, D, E, F, G])
w.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]
```
