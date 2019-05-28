# Graphs

### WTGraph
```@docs
Graphs.WTGraph
Graphs.add_edges(g::WTGraph{T}, edge::WTEdge{T}) where T
Graphs.add_edges(g::WTGraph{T}, edges::WTEdges{T}) where T
Graphs.add_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
Graphs.add_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
Graphs.remove_edges(g::WTGraph{T}, edge::WTEdge{T}) where T
Graphs.remove_edges(g::WTGraph{T}, edges::WTEdges{T}) where T
Graphs.remove_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
Graphs.remove_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
```

### WTEdges
```@docs
Graphs.WTEdges
Graphs.union(args::Union{WTEdge{T}, WTEdges{T}}...) where T
```

### WTEdge
```@docs
Graphs.WTEdge
Graphs.:⇿
Graphs.:→
Graphs.:←
Graphs.:⇄
Graphs.:⇆
```

### WTNode
```@docs
Graphs.WTNode
Graphs.@nodes
```

### Weighted
```@docs
Graphs.Weighted
Graphs.add_edges!(callback, w::Weighted{T, WT}, arg::Array{Any, 2}) where {T, WT}
Graphs.remove_edges!(callback, w::Weighted{T, WT}, edge::WTEdge{T}) where {T, WT}
Graphs.remove_edges!(callback, w::Weighted{T, WT}, edges::WTEdges{T}) where {T, WT}
```
