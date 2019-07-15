# module Tutte.Graphs

using LightGraphs.SimpleGraphs: SimpleGraphs, SimpleGraph, SimpleDiGraph, LGFormat

# SimpleGraph{<:Integer}
function simplegraph_nodes(vertices::Vector{NT}, edges::WTEdges{NT})::Tuple{SimpleGraph{<:Integer}, Vector{NT}} where NT
    r = SimpleGraph{<:Integer}(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simplegraph_nodes(edges::WTEdges{NT})::Tuple{SimpleGraph{<:Integer}, Vector{NT}} where NT
    vertices = sort(collect(allnodes(edges)))
    simplegraph_nodes(vertices, edges)
end

function simplegraph_nodes(g::WTGraph{NT})::Tuple{SimpleGraph{<:Integer}, Vector{NT}} where NT
    simplegraph_nodes(g.edges)
end

# SimpleDiGraph{<:Integer}
function simpledigraph_nodes(vertices::Vector{NT}, edges::WTEdges{NT})::Tuple{SimpleDiGraph{<:Integer}, Vector{NT}} where NT
    r = SimpleDiGraph{<:Integer}(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simpledigraph_nodes(edges::WTEdges{NT})::Tuple{SimpleDiGraph{<:Integer}, Vector{NT}} where NT
    vertices = sort(collect(allnodes(edges)))
    simpledigraph_nodes(vertices, edges)
end

function simpledigraph_nodes(g::WTGraph{NT})::Tuple{SimpleDiGraph{<:Integer}, Vector{NT}} where NT
    simpledigraph_nodes(g.edges)
end

# WTGraph{T}
function WTGraph{T}(sg::SimpleGraph{ST}, nodes::Vector{T})::WTGraph{T} where {T, ST}
    WTGraph{T}(Set{T}(nodes), WTEdges([WTEdge(⇿, (nodes[edge.src], nodes[edge.dst]), false) for edge in SimpleGraphs.edges(sg)]))
end

function WTGraph(sg::SimpleGraph{ST}, nodes::Vector{T})::WTGraph{T} where {T, ST}
    WTGraph{T}(sg, nodes)
end

function WTGraph{T}(sg::SimpleGraph{ST})::WTGraph{T} where {T, ST}
    WTGraph{T}(sg, Vector{T}(SimpleGraphs.vertices(sg)))
end

function WTGraph(sg::SimpleGraph{T})::WTGraph{T} where T
    WTGraph{T}(sg)
end

function WTGraph{T}(sg::SimpleDiGraph{ST}, nodes::Vector{T})::WTGraph{T} where {T, ST}
    WTGraph{T}(Set{T}(nodes), WTEdges([WTEdge(→, (nodes[edge.src], nodes[edge.dst]), false) for edge in SimpleGraphs.edges(sg)]))
end

function WTGraph{T}(sg::SimpleDiGraph{ST})::WTGraph{T} where {T, ST}
    WTGraph{T}(sg, Vector{T}(SimpleGraphs.vertices(sg)))
end

function WTGraph(sg::SimpleDiGraph{ST}, nodes::Vector{T})::WTGraph{T} where {T, ST}
    WTGraph{T}(sg, nodes)
end

function WTGraph(sg::SimpleDiGraph{T})::WTGraph{T} where T
    WTGraph{T}(sg)
end

function savegraph(io::IO, g::AbstractGraph{T}) where T
    SimpleGraphs.savegraph(io, g, LGFormat())
end

function loadgraph(io::IO)
    SimpleGraphs.loadgraph(io, "graph", LGFormat())
end

# module Tutte.Graphs
