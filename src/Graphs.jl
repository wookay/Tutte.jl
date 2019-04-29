module Graphs # Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge, SimpleGraphs
export Graph, Edge, Edges, Node, @nodes, ⇿, →, ←, ⇄, ⇆, addedges, cutedges, addedges!, cutedges!

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
    function Edges(list::Vector{Edge}; isunique=false)
        if isunique
            new(list)
        else
            edges = Vector{Edge}()
            @inbounds for edge in list
                !(edge in edges) && push!(edges, edge)
            end
            new(edges)
        end
    end
end

struct Graph <: AbstractGraph{Symbol}
    nodes::Set
    edges::Edges
    function Graph()
        new(Set(), Edges(Vector{Edge}(), isunique=true))
    end
    function Graph(nodes::Set, edges::Edges)
        new(nodes, edges)
    end
    function Graph(edges::Edges)
        new(Set(allnodes(edges)), edges)
    end
end

macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(id -> Node(id), s)))
end

import Base: ==, union, isempty, isless

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

function isless(a::Node, b::Node)
    a.id < b.id
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
    Edges([→(a, b), ←(a, b)], isunique=true)
end

function ⇄(a::Any, edge::Edge)::Edges
    Edges([⇄(a, nodeof(edge, first)).list..., edge])
end

# ⇆  \leftrightarrows<tab>
function ⇆(a::Any, b::Any)::Edges
    Edges([←(a, b), →(a, b)], isunique=true)
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

function union(args::Union{Edge, Edges}...)::Edges
    list = Vector{Edge}()
    @inbounds for arg in args
        if arg isa Edge
            !(arg in list) && push!(list, arg)
        elseif arg isa Edges
            for edge in arg.list
                !(edge in list) && push!(list, edge)
            end
        end
    end
    Edges(list, isunique=true)
end

function ==(a::Edge, b::Edge)
    if a.op === b.op === ⇿
        Set(a.nodes) == Set(b.nodes)
    else
        (a.op === b.op) && (a.nodes == b.nodes)
    end
end

function ==(l::Edges, r::Edges)
    length(l.list) == length(r.list) || return false
    a = Dict(((edge.op === ⇿) ? Set(edge.nodes) : edge.nodes) => edge.op for edge in l.list)
    b = Dict(((edge.op === ⇿) ? Set(edge.nodes) : edge.nodes) => edge.op for edge in r.list)
    a == b
end

function ==(l::Graph, r::Graph)
    l.nodes == r.nodes && l.edges == r.edges
end

function addedges(g::Graph, edge::Edge)::Graph
    addedges(g, Edges([edge], isunique=true))
end

function addedges(g::Graph, edges::Edges)::Graph
    list = Vector{Edge}(g.edges.list)
    nodes = Set(g.nodes)
    @inbounds for edge in edges.list
        if !(edge in g.edges.list)
            push!(list, edge)
            push!(nodes, edge.nodes...)
        end
    end
    concatedges = Edges(list, isunique=true)
    Graph(nodes, concatedges)
end

function addedges!(callback, g::Graph, edge::Edge)
    addedges!(callback, g, Edges([edge], isunique=true))
end

function addedges!(callback, g::Graph, edges::Edges)
    list = Vector{Edge}()
    nodes = Set()
    @inbounds for edge in edges.list
        if !(edge in g.edges.list)
            push!(list, edge)
            push!(nodes, edge.nodes...)
        end
    end
    if !isempty(list)
        append!(g.edges.list, list)
        push!(g.nodes, nodes...)
        callback(list, nodes)
    end
end

function cutedges(g::Graph, edge::Edge)::Graph
    cutedges(g, Edges([edge], isunique=true))
end

function cutedges(g::Graph, edges::Edges)::Graph
    list = g.edges.list
    indices = filter(!isnothing, indexin(list, edges.list))
    Graph(g.nodes, Edges(g.edges.list[setdiff(1:length(list), indices)], isunique=true))
end

function cutedges!(callback, g::Graph, edge::Edge)
    cutedges!(callback, g, Edges([edge], isunique=true))
end

function cutedges!(callback, g::Graph, edges::Edges)
    indices = filter(!isnothing, indexin(g.edges.list, edges.list))
    if length(g.edges.list) != length(indices)
        list = g.edges.list[indices]
        nodes = Set()
        for edge in list
            push!(nodes, edge.nodes...)
        end
        deleteat!(g.edges.list, indices)
        callback(list, nodes)
    end
end

function allnodes(edges::Edges)::Vector{Any}
    vcat(map(edge -> collect(edge.nodes), edges.list)...)
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
    @inbounds for (idx, edge) in enumerate(edges.list)
        Base.show(io, mime, edge)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

include("lightgraphs.jl")

end # module Tutte.Graphs
