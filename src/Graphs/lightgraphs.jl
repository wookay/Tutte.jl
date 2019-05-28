# module Tutte.Graphs

using LightGraphs.SimpleGraphs: SimpleGraphs, SimpleGraph, SimpleDiGraph, LGFormat

# SimpleGraph
function simplegraph_nodes(vertices::Vector{T}, edges::WTEdges{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    r = SimpleGraph(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simplegraph_nodes(edges::WTEdges{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    vertices = sort(collect(allnodes(edges)))
    simplegraph_nodes(vertices, edges)
end

function simplegraph_nodes(g::WTGraph{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    simplegraph_nodes(g.edges)
end

# SimpleDiGraph
function simpledigraph_nodes(vertices::Vector{T}, edges::WTEdges{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
    r = SimpleDiGraph(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simpledigraph_nodes(edges::WTEdges{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
    vertices = sort(collect(allnodes(edges)))
    simpledigraph_nodes(vertices, edges)
end

function simpledigraph_nodes(g::WTGraph{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
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
