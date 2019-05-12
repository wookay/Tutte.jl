module Graphs # Tutte

export Graph, Edge, Edges, Node, @nodes, ⇿, →, ←, ⇄, ⇆, addedges, cutedges, addedges!, cutedges!
include("Graphs/graphs.jl")

export Weighted
include("Graphs/weighted.jl")

export IDMap, indexof
include("Graphs/lightgraphs.jl")

end # module Tutte.Graphs
