module Graphs # Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge
export Graph, Edge, Edges, Node, @nodes, →, ←, addedges, cutedges

struct Node
    props::Dict
end

struct Edge <: AbstractEdge{Symbol}
    op
    nodes::Tuple{Node, Node}
    props::Dict
end

struct Edges
    list::Vector{Edge}
    function Edges(list::Vector{Edge})
        new(unique(list) do edge
            e = toright(edge)
            (e.op, e.nodes, e.props)
        end)
    end
end

struct Graph <: AbstractGraph{Symbol}
    nodes::Set{Node}
    edges::Edges
    props::Dict
    function Graph()
        new(Set{Node}(), Edges(Vector{Edge}()), Dict())
    end
    function Graph(nodes::Set{Node}, edges::Edges)
        new(nodes, edges, Dict())
    end
    function Graph(nodes::Set{Node}, edges::Edges, props::Dict)
        new(nodes, edges, props)
    end
end

macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(x -> Node(Dict(:id => x, :label => String(x))), s)))
end

import Base: -, ==, ∪, isempty, isless

function isempty(g::Graph)
    isempty(g.nodes) && isempty(g.edges)
end

function isempty(edges::Edges)
    isempty(edges.list)
end

function -(a::Node, b::Node)::Edge
    Edge(-, (a, b), Dict())
end

function →(a::Node, b::Node)::Edge
    Edge(→, (a, b), Dict())
end

function ←(a::Node, b::Node)::Edge
    Edge(←, (a, b), Dict())
end

function -(edge::Edge, b::Node)::Edges
    Edges([edge, last(edge.nodes) - b])
end

function →(edge::Edge, b::Node)::Edges
    Edges([edge, last(edge.nodes) → b])
end

function →(a::Edge, b::Edge)::Edges
    Edges([a, last(a.nodes) → first(b.nodes), b])
end

function ←(a::Edge, b::Edge)::Edges
    Edges([a, last(a.nodes) ← first(b.nodes), b])
end

function ←(a::Node, edge::Edge)::Edges
    Edges([a ← first(edge.nodes), edge])
end

function toright(edge::Edge)
    if edge.op == ←
        Edge(→, reverse(edge.nodes), edge.props)
    else
        edge
    end
end

function ==(l::Edge, r::Edge)
    a, b = toright(l), toright(r)
    if a.op == b.op == -
        (Set(a.nodes) == Set(b.nodes)) && (a.props == b.props)
    else
        (a.op == b.op) && (a.nodes == b.nodes) && (a.props == b.props)
    end
end

function ∪(edges::Edge...)::Edges
    Edges(Edge[toright.(edges)...])
end

function ==(l::Edges, r::Edges)
    length(l.list) == length(r.list) && all(sort(l.list) .== sort(r.list))
end

function ==(l::Node, r::Node)
    idof(l) == idof(r)
end

function idof(node::Node)
    node.props[:id]
end

function idof(edge::Edge)
    (Symbol(edge.op), idof.(edge.nodes))
end

function isless(l::Edge, r::Edge)
    isless(idof(toright(l)), idof(toright(r)))
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
    idlist = (idof ∘ toright).(g.edges.list)
    indices = filter(!isnothing, indexin(idlist, (idof ∘ toright).(edges.list)))
    Graph(g.nodes, Edges(g.edges.list[setdiff(1:length(idlist), indices)]), g.props)
end

function allnodes(edges::Edges)::Vector{Node}
    vcat(map(edge -> [edge.nodes...], edges.list)...)
end

function Base.show(io::IO, mime::MIME"text/plain", edge::Edge)
    print(io, first(edge.nodes).props[:id], ' ', nameof(edge.op), ' ', last(edge.nodes).props[:id])
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
