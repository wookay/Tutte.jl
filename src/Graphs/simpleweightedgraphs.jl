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

# Weighted{T,W}
function _build_weighted(wg::Union{SimpleWeightedGraph{<:Integer,W}, SimpleWeightedDiGraph{<:Integer,W}}, nodes::Vector{T}, op) where {T, W}
    edges = WTEdge{T}[]
    weights = W[]
    for edge in SimpleWeightedGraphs.edges(wg)
        push!(edges, WTEdge{T}(op, (nodes[edge.src], nodes[edge.dst]), false))
        push!(weights, edge.weight)
    end
    graph = WTGraph{T}(Set{T}(nodes), WTEdges{T}(edges))
    Weighted{T,W}(graph, weights)
end

function Weighted{T,W}(wg::SimpleWeightedGraph{<:Integer,W}, nodes::Vector{T}) where {T, W}
    _build_weighted(wg, nodes, ⇿)
end

function Weighted(wg::SimpleWeightedGraph{<:Integer,W}, nodes::Vector{T}) where {T, W}
    Weighted{T,W}(wg, nodes)
end

function Weighted{T,W}(wg::SimpleWeightedDiGraph{<:Integer,W}, nodes::Vector{T}) where {T, W}
    _build_weighted(wg, nodes, →)
end

function Weighted(wg::SimpleWeightedDiGraph{<:Integer,W}, nodes::Vector{T}) where {T, W}
    Weighted{T,W}(wg, nodes)
end

# module Tutte.Graphs
