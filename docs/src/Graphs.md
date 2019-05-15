# Graphs

### Graph
```@docs
Graphs.Graph
Graphs.addedges(g::Graph{T}, edge::Edge{T}) where T
Graphs.addedges(g::Graph{T}, edges::Edges{T}) where T
Graphs.addedges!(callback, g::Graph{T}, edge::Edge{T}) where T
Graphs.addedges!(callback, g::Graph{T}, edges::Edges{T}) where T
Graphs.cutedges(g::Graph{T}, edge::Edge{T}) where T
Graphs.cutedges(g::Graph{T}, edges::Edges{T}) where T
Graphs.cutedges!(callback, g::Graph{T}, edge::Edge{T}) where T
Graphs.cutedges!(callback, g::Graph{T}, edges::Edges{T}) where T
```

### Edges
```@docs
Graphs.Edges
Graphs.union(args::Union{Edge{T}, Edges{T}}...) where T
```

### Edge
```@docs
Graphs.Edge
Graphs.:⇿
Graphs.:→
Graphs.:←
Graphs.:⇄
Graphs.:⇆
```

### Node
```@docs
Graphs.Node
Graphs.@nodes
```

### Weighted
```@docs
Graphs.Weighted
Graphs.addedges!(callback, w::Weighted{T, WT}, arg::Array{Any, 2}) where {T, WT}
Graphs.cutedges!(callback, w::Weighted{T, WT}, edge::Edge{T}) where {T, WT}
Graphs.cutedges!(callback, w::Weighted{T, WT}, edges::Edges{T}) where {T, WT}
```
