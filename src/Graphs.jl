module Graphs # Tutte

export WTGraph, WTEdge, WTEdges, WTNode, @nodes, ⇿, →, ←, ⇄, ⇆, add_edges, remove_edges, add_edges!, remove_edges!
include("Graphs/graphs.jl")

export Weighted
include("Graphs/weighted.jl")

include("Graphs/lightgraphs.jl")
include("Graphs/simpleweightedgraphs.jl")

end # module Tutte.Graphs
