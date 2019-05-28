# Tutte ፨

|  **Documentation**                        |  **Build Status**                                               |
|:-----------------------------------------:|:---------------------------------------------------------------:|
|  [![][docs-latest-img]][docs-latest-url]  |  [![][travis-img]][travis-url] [![][codecov-img]][codecov-url]  |


```julia
using Tutte.Graphs # @nodes WTGraph Weighted →
@nodes A B C D E F G
g = WTGraph(union(A → C → F → G, A → D → F, B → D → G, B → E → G))
w = Weighted([A 5→ C 2→ F 1→ G], [A 3→ D 4→ F], [B 9→ D 8→ G], [B 6→ E 4→ G])
w.graph == g
w.graph.edges.list == [A → C, C → F, F → G, A → D, D → F, B → D, D → G, B → E, E → G]
w.graph.nodes == Set([A, B, C, D, E, F, G])
w.weights == [5, 2, 1, 3, 4, 9, 8, 6, 4]
```

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://wookay.github.io/docs/Tutte.jl/

[travis-img]: https://api.travis-ci.org/wookay/Tutte.jl.svg?branch=master
[travis-url]: https://travis-ci.org/wookay/Tutte.jl

[codecov-img]: https://codecov.io/gh/wookay/Tutte.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/wookay/Tutte.jl/branch/master
