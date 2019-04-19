module Graphs # Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge
export Graph, Edge, Edges, Node, @nodes, ⇿, →, ←, ⇄, ⇆, addedges, cutedges

struct Node
    id::Symbol
end

struct Edge <: AbstractEdge{Symbol}
    op
    nodes::Tuple{Any, Any}
    backward::Bool
end

struct Edges
    list::Vector{Edge}
    function Edges(list::Vector{Edge})
        new(unique(list) do edge
            (edge.op, edge.nodes, false)
        end)
    end
end

struct Graph <: AbstractGraph{Symbol}
    nodes::Set{Any}
    edges::Edges
    function Graph()
        new(Set{Any}(), Edges(Vector{Edge}()))
    end
    function Graph(nodes::Set{Any}, edges::Edges)
        new(nodes, edges)
    end
end

macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(id -> Node(id), s)))
end

import Base: ==, ∪, isempty, isless

function isempty(g::Graph)
    isempty(g.nodes) && isempty(g.edges)
end

function isempty(edges::Edges)
    isempty(edges.list)
end

function nodeof(edge::Edge, ::typeof(first))
    edge.backward ? edge.nodes[2] : edge.nodes[1]
end

function nodeof(edge::Edge, ::typeof(last))
    edge.backward ? edge.nodes[1] : edge.nodes[2]
end

# ⇿  \leftrightarrowtriangle<tab>
function ⇿(a::Any, b::Any)::Edge
    Edge(⇿, (a, b), false)
end

# →  \rightarrow<tab>
function →(a::Any, b::Any)::Edge
    Edge(→, (a, b), false)
end

# ←  \leftarrow<tab>
function ←(a::Any, b::Any)::Edge
    Edge(→, (b, a), true)
end

# ⇄  \rightleftarrows<tab>
function ⇄(a::Any, b::Any)::Edges
    Edges([→(a, b), ←(a, b)])
end

function ⇄(a::Any, edge::Edge)::Edges
    Edges([⇄(a, nodeof(edge, first)).list..., edge])
end

# ⇆  \leftrightarrows<tab>
function ⇆(a::Any, b::Any)::Edges
    Edges([←(a, b), →(a, b)])
end

function ⇆(a::Any, edge::Edge)::Edges
    Edges([⇆(a, nodeof(edge, first)).list..., edge])
end

for arrow in (:⇿, :→, :←)
    @eval function ($arrow)(a::Any, edges::Edges)::Edges
        edge = first(edges.list)
        Edges([$arrow(a, nodeof(edge, first)), edges.list...])
    end

    @eval function ($arrow)(a::Any, edge::Edge)::Edges
        Edges([$arrow(a, nodeof(edge, first)), edge])
    end

    @eval function ($arrow)(edge::Edge, b::Any)::Edges
        Edges([edge, $arrow(nodeof(edge, last), b)])
    end
end

function ∪(edges::Edge...)::Edges
    Edges([edges...])
end

function ==(a::Node, b::Node)
    idof(a) == idof(b)
end

function ==(a::Edge, b::Edge)
    if a.op === b.op === ⇿
        Set(a.nodes) == Set(b.nodes)
    else
        (a.op === b.op) && (a.nodes == b.nodes)
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
    Graph(nodes, concatedges)
end

function cutedges(g::Graph, edge::Edge)::Graph
    cutedges(g, Edges([edge]))
end

function cutedges(g::Graph, edges::Edges)::Graph
    idlist = idof.(g.edges.list)
    indices = filter(!isnothing, indexin(idlist, idof.(edges.list)))
    Graph(g.nodes, Edges(g.edges.list[setdiff(1:length(idlist), indices)]))
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
