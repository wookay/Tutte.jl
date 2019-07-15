# module Tutte.Graphs

using SimpleWeightedGraphs: SimpleWeightedGraphs, SimpleWeightedGraph, SimpleWeightedDiGraph, SimpleWeightedGraphEdge

# SimpleWeightedGraph{Int,W}
function simpleweightedgraph_nodes(vertices::Vector{NT}, edges::WTEdges{NT}, weights::Vector{W})::Tuple{SimpleWeightedGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    r = SimpleWeightedGraph{Int,W}(length(vertices))
    for (edge, weight) in zip(edges.list, weights)
        SimpleWeightedGraphs.add_edge!(r, SimpleWeightedGraphEdge(indexin(edge.nodes, vertices)..., weight))
    end
    (r, vertices)
end

function simpleweightedgraph_nodes(edges::WTEdges{NT}, weights::Vector{W})::Tuple{SimpleWeightedGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    vertices = sort(collect(allnodes(edges)))
    simpleweightedgraph_nodes(vertices, edges, weights)
end

function simpleweightedgraph_nodes(w::Weighted{NT,W})::Tuple{SimpleWeightedGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    simpleweightedgraph_nodes(w.graph.edges, w.weights)
end

# SimpleWeightedDiGraph{Int,W}
function simpleweighteddigraph_nodes(vertices::Vector{NT}, edges::WTEdges{NT}, weights::Vector{W})::Tuple{SimpleWeightedDiGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    r = SimpleWeightedDiGraph{Int,W}(length(vertices))
    for (edge, weight) in zip(edges.list, weights)
        SimpleWeightedGraphs.add_edge!(r, SimpleWeightedGraphEdge(indexin(edge.nodes, vertices)..., weight))
    end
    (r, vertices)
end

function simpleweighteddigraph_nodes(edges::WTEdges{NT}, weights::Vector{W})::Tuple{SimpleWeightedDiGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    vertices = sort(collect(allnodes(edges)))
    simpleweighteddigraph_nodes(vertices, edges, weights)
end

function simpleweighteddigraph_nodes(w::Weighted{NT,W})::Tuple{SimpleWeightedDiGraph{<:Integer,W}, Vector{NT}} where {NT, W}
    simpleweighteddigraph_nodes(w.graph.edges, w.weights)
end

# module Tutte.Graphs
