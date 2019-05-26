module Graphs # Tutte

export Graph, Edge, Edges, Node, @nodes, ⇿, →, ←, ⇄, ⇆, add_edges, remove_edges, add_edges!, remove_edges!
include("Graphs/graphs.jl")

export Weighted
include("Graphs/weighted.jl")

include("Graphs/lightgraphs.jl")

end # module Tutte.Graphs
