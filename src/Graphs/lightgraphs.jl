# module Tutte.Graphs

using LightGraphs.SimpleGraphs: SimpleGraphs, SimpleGraph, SimpleDiGraph, LGFormat, add_edge!, vertices, edges, savegraph, loadgraph

struct IDMap{T}
    vertices::Vector{T}
    function IDMap(g::Graph{T}) where T
        sortednodes = sort(collect(g.nodes))
        new{T}(sortednodes)
    end
end

function Base.getindex(idmap::IDMap{T}, nth::Integer)::T where T
    idmap.vertices[nth]
end

function indexof(idmap::IDMap{T}, node::T)::Union{Integer, Nothing} where T
    for (i, vertice) in enumerate(idmap.vertices)
        vertice == node && return i
    end
    return nothing
end

function SimpleGraph(nodes::Set{T}, edges::Edges{T})::SimpleGraph{Int} where T
    vertices = sort(collect(nodes))
    len = length(vertices)
    dict = Dict(zip(vertices, 1:len))
    r = SimpleGraph(len)
    for edge in edges.list
        add_edge!(r, getindex.(Ref(dict), edge.nodes)...)
    end
    r
end

function SimpleGraph(g::Graph)::SimpleGraph{Int}
    SimpleGraph(g.nodes, g.edges)
end

function SimpleGraph(edges::Edges)::SimpleGraph{Int}
    SimpleGraph(Set(allnodes(edges)), edges)
end

function SimpleDiGraph(nodes::Set{T}, edges::Edges{T})::SimpleDiGraph{Int} where T
    vertices = sort(collect(nodes))
    len = length(vertices)
    dict = Dict(zip(vertices, 1:len))
    r = SimpleDiGraph(len)
    for edge in edges.list
        add_edge!(r, getindex.(Ref(dict), edge.nodes)...)
    end
    r
end

function SimpleDiGraph(g::Graph)::SimpleDiGraph{Int}
    SimpleDiGraph(g.nodes, g.edges)
end

function SimpleDiGraph(edges::Edges)::SimpleDiGraph{Int}
    SimpleDiGraph(Set(allnodes(edges)), edges)
end

function Graph(sg::SimpleGraph{Int})
    Graph(Set{Int}(collect(vertices(sg))), Edges([Edge(⇿, (edge.src, edge.dst), false) for edge in edges(sg)]))
end

function Graph(sg::SimpleDiGraph{Int})
    Graph(Set{Int}(collect(vertices(sg))), Edges([Edge(→, (edge.src, edge.dst), false) for edge in edges(sg)]))
end

function SimpleGraphs.savegraph(io::IO, g::AbstractGraph)
    SimpleGraphs.savegraph(io, g, LGFormat())
end

function SimpleGraphs.loadgraph(io::IO)
    SimpleGraphs.loadgraph(io, "graph", LGFormat())
end

# module Tutte.Graphs
