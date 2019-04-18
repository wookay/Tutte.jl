module Graphs # Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge
export Graph, Edge, Edges, Node, @nodes, ⇿, →, ←, addedges, cutedges

struct Node
    id::Symbol
    props::Dict
    function Node(; id::Symbol, props::Dict=Dict())
        new(id, props)
    end
end

struct Edge <: AbstractEdge{Symbol}
    op
    nodes::Tuple{Any, Any}
    backward::Bool
    props::Dict
end

struct Edges
    list::Vector{Edge}
    function Edges(list::Vector{Edge})
        new(unique(list) do edge
            (edge.op, edge.nodes, false, edge.props)
        end)
    end
end

struct Graph <: AbstractGraph{Symbol}
    nodes::Set{Any}
    edges::Edges
    props::Dict
    function Graph()
        new(Set{Any}(), Edges(Vector{Edge}()), Dict())
    end
    function Graph(nodes::Set{Any}, edges::Edges)
        new(nodes, edges, Dict())
    end
    function Graph(nodes::Set{Any}, edges::Edges, props::Dict)
        new(nodes, edges, props)
    end
end

macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(x -> Node(; id=x), s)))
end

import Base: ==, ∪, isempty, isless

function isempty(g::Graph)
    isempty(g.nodes) && isempty(g.edges)
end

function isempty(edges::Edges)
    isempty(edges.list)
end

function ⇿(a::Any, b::Any)::Edge
    Edge(⇿, (a, b), false, Dict())
end

function ⇿(a::Any, edge::Edge)::Edges
    Edges([a ⇿ (edge.backward ? last : first)(edge.nodes), edge])
end

function ⇿(edge::Edge, b::Any)::Edges
    Edges([edge, (edge.backward ? first : last)(edge.nodes) ⇿ b])
end

function ⇿(a::Any, edges::Edges)::Edges
    edge = first(edges.list)
    Edges([a ⇿ (edge.backward ? last : first)(edge.nodes), edges.list...])
end

function →(a::Any, b::Any)::Edge
    Edge(→, (a, b), false, Dict())
end

function →(a::Any, edge::Edge)::Edges
    Edges([a → (edge.backward ? last : first)(edge.nodes), edge])
end

function →(edge::Edge, b::Any)::Edges
    Edges([edge, (edge.backward ? first : last)(edge.nodes) → b])
end

function ←(a::Any, b::Any)::Edge
    Edge(→, (b, a), true, Dict())
end

function ←(a::Any, edge::Edge)::Edges
    Edges([a ← (edge.backward ? last : first)(edge.nodes), edge])
end

function ←(edge::Edge, b::Any)::Edges
    Edges([edge, (edge.backward ? first : last)(edge.nodes) ←  b])
end

function ∪(edges::Edge...)::Edges
    Edges([edges...])
end

function ==(a::Node, b::Node)
    idof(a) == idof(b)
end

function ==(a::Edge, b::Edge)
    if a.op === b.op === ⇿
        (Set(a.nodes) == Set(b.nodes)) && (a.props == b.props)
    else
        (a.op === b.op) && (a.nodes == b.nodes) && (a.props == b.props)
    end
end

function ==(l::Edges, r::Edges)
    length(l.list) == length(r.list) && all(sort(l.list) .== sort(r.list))
end

function idof(node::Any)
    node
end

function idof(node::Node)
    node.id
end

function idof(edge::Edge)
    (Symbol(edge.op), idof.(edge.nodes))
end

function isless(l::Edge, r::Edge)
    isless(idof(l), idof(r))
end

function isless(l::Node, r::Node)
    isless(idof(l), idof(r))
end

function addedges(g::Graph, edge::Edge)::Graph
    addedges(g, Edges([edge]))
end

function addedges(g::Graph, edges::Edges)::Graph
    concatedges = Edges(vcat(g.edges.list, edges.list))
    nodes = union(g.nodes, allnodes(concatedges))
    Graph(nodes, concatedges, g.props)
end

function cutedges(g::Graph, edge::Edge)::Graph
    cutedges(g, Edges([edge]))
end

function cutedges(g::Graph, edges::Edges)::Graph
    idlist = idof.(g.edges.list)
    indices = filter(!isnothing, indexin(idlist, idof.(edges.list)))
    Graph(g.nodes, Edges(g.edges.list[setdiff(1:length(idlist), indices)]), g.props)
end

function allnodes(edges::Edges)::Vector{Any}
    vcat(map(edge -> [edge.nodes...], edges.list)...)
end

function Base.show(io::IO, mime::MIME"text/plain", edge::Edge)
    if (edge.op === →) && edge.backward
        Base.show(io, mime, last(edge.nodes))
        print(io, ' ', nameof(←), ' ')
        Base.show(io, mime, first(edge.nodes))
    else
        Base.show(io, mime, first(edge.nodes))
        print(io, ' ', nameof(edge.op), ' ')
        Base.show(io, mime, last(edge.nodes))
    end
end

function Base.show(io::IO, mime::MIME"text/plain", edges::Edges)
    count = length(edges.list)
    print(io, "Edges([")
    for (idx, edge) in enumerate(edges.list)
        Base.show(io, mime, edge)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

end # module Tutte.Graphs
