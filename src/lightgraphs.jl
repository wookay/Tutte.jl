# module Tutte.Graphs

using .SimpleGraphs: SimpleGraph, SimpleDiGraph, add_edge!

function SimpleGraph(nodes::Set{Any}, edges::Edges)::SimpleGraph
    vertices = sort(collect(nodes))
    len = length(vertices)
    dict = Dict(zip(vertices, 1:len))
    r = SimpleGraph(len)
    for edge in edges.list
        add_edge!(r, getindex.(Ref(dict), edge.nodes)...)
    end
    r
end

function SimpleGraph(edges::Edges)::SimpleGraph
    SimpleGraph(Set(allnodes(edges)), edges)
end

function SimpleGraph(g::Graph)::SimpleGraph
    SimpleGraph(g.nodes, g.edges)
end

function SimpleDiGraph(nodes::Set{Any}, edges::Edges)::SimpleDiGraph
    vertices = sort(collect(nodes))
    len = length(vertices)
    dict = Dict(zip(vertices, 1:len))
    r = SimpleDiGraph(len)
    for edge in edges.list
        add_edge!(r, getindex.(Ref(dict), edge.nodes)...)
    end
    r
end

function SimpleDiGraph(edges::Edges)::SimpleDiGraph
    SimpleDiGraph(Set(allnodes(edges)), edges)
end

function SimpleDiGraph(g::Graph)::SimpleDiGraph
    SimpleDiGraph(g.nodes, g.edges)
end

# module Tutte.Graphs
