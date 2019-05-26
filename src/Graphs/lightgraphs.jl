# module Tutte.Graphs

using LightGraphs.SimpleGraphs: SimpleGraphs, SimpleGraph, SimpleDiGraph, LGFormat

# SimpleGraph
function simplegraph_nodes(vertices::Vector{T}, edges::Edges{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    r = SimpleGraph(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simplegraph_nodes(edges::Edges{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    vertices = sort(collect(allnodes(edges)))
    simplegraph_nodes(vertices, edges)
end

function simplegraph_nodes(g::Graph{T})::Tuple{SimpleGraph{Int}, Vector{T}} where T
    simplegraph_nodes(g.edges)
end

# SimpleDiGraph
function simpledigraph_nodes(vertices::Vector{T}, edges::Edges{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
    r = SimpleDiGraph(length(vertices))
    for edge in edges.list
        SimpleGraphs.add_edge!(r, indexin(edge.nodes, vertices)...)
    end
    (r, vertices)
end

function simpledigraph_nodes(edges::Edges{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
    vertices = sort(collect(allnodes(edges)))
    simpledigraph_nodes(vertices, edges)
end

function simpledigraph_nodes(g::Graph{T})::Tuple{SimpleDiGraph{Int}, Vector{T}} where T
    simpledigraph_nodes(g.edges)
end

# Graph{T}
function Graph{T}(sg::SimpleGraph{ST}, nodes::Vector{T})::Graph{T} where {T, ST}
    Graph{T}(Set{T}(nodes), Edges([Edge(⇿, (nodes[edge.src], nodes[edge.dst]), false) for edge in SimpleGraphs.edges(sg)]))
end

function Graph(sg::SimpleGraph{ST}, nodes::Vector{T})::Graph{T} where {T, ST}
    Graph{T}(sg, nodes)
end

function Graph{T}(sg::SimpleGraph{ST})::Graph{T} where {T, ST}
    Graph{T}(sg, Vector{T}(SimpleGraphs.vertices(sg)))
end

function Graph(sg::SimpleGraph{T})::Graph{T} where T
    Graph{T}(sg)
end

function Graph{T}(sg::SimpleDiGraph{ST}, nodes::Vector{T})::Graph{T} where {T, ST}
    Graph{T}(Set{T}(nodes), Edges([Edge(→, (nodes[edge.src], nodes[edge.dst]), false) for edge in SimpleGraphs.edges(sg)]))
end

function Graph{T}(sg::SimpleDiGraph{ST})::Graph{T} where {T, ST}
    Graph{T}(sg, Vector{T}(SimpleGraphs.vertices(sg)))
end

function Graph(sg::SimpleDiGraph{ST}, nodes::Vector{T})::Graph{T} where {T, ST}
    Graph{T}(sg, nodes)
end

function Graph(sg::SimpleDiGraph{T})::Graph{T} where T
    Graph{T}(sg)
end

function savegraph(io::IO, g::AbstractGraph)
    SimpleGraphs.savegraph(io, g, LGFormat())
end

function loadgraph(io::IO)
    SimpleGraphs.loadgraph(io, "graph", LGFormat())
end

# module Tutte.Graphs
