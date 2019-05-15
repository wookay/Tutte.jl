# module Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge

"""
    Node
"""
struct Node
    id::Symbol
end

"""
    Edge{T}
"""
struct Edge{T} <: AbstractEdge{T}
    op
    nodes::Tuple{T, T}
    backward::Bool
end

"""
    Edges{T}
"""
struct Edges{T}
    list::Vector{Edge{T}}

    # Edges{Node}([])
    function Edges{T}(list::Vector{Any}) where T
        new{T}(list)
    end

    function Edges{T}(list::Vector{Edge{T}}; isunique=false) where T
        if isunique
            new{T}(list)
        else
            edges = Vector{Edge{T}}()
            @inbounds for edge in list
                !(edge in edges) && push!(edges, edge)
            end
            new{T}(edges)
        end
    end

    function Edges(list::Vector{Edge{T}}; isunique=false) where T
        Edges{T}(list; isunique=isunique)
    end
end # struct Edges{T}

"""
    Graph{T}
"""
struct Graph{T} <: AbstractGraph{T}
    nodes::Set{T}
    edges::Edges{T}

    function Graph{T}(nodes::Set{T}, edges::Edges{T}) where T
        new{T}(nodes, edges)
    end

    function Graph{T}(edges::Edges{T}) where T
        Graph{T}(Set{T}(allnodes(edges)), edges)
    end

    function Graph{T}(edge::Edge{T}) where T
        Graph{T}(Edges([edge]; isunique=true))
    end

    function Graph{T}() where T
        Graph{T}(Set{T}(), Edges(Vector{Edge{T}}(), isunique=true))
    end

    function Graph(nodes::Set{T}, edges::Edges{T}) where T
        Graph{T}(nodes, edges)
    end

    function Graph(edges::Edges{T}) where T
        Graph{T}(edges)
    end

    function Graph(edge::Edge{T}) where T
        Graph{T}(Edges([edge]; isunique=true))
    end
end # struct Graph{T} <: AbstractGraph{T}

"""
    @nodes
"""
macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(id -> Node(id), s)))
end

import Base: ==, union, isempty, isless

function isempty(g::Graph{T}) where T
    isempty(g.nodes) && isempty(g.edges)
end

function isempty(edges::Edges{T}) where T
    isempty(edges.list)
end

function nodeof(edge::Edge{T}, ::typeof(first)) where T
    edge.backward ? edge.nodes[2] : edge.nodes[1]
end

function nodeof(edge::Edge{T}, ::typeof(last)) where T
    edge.backward ? edge.nodes[1] : edge.nodes[2]
end

function isless(a::Node, b::Node)
    a.id < b.id
end

# ⇿  \leftrightarrowtriangle<tab>
"""
    ⇿
"""
function ⇿(a::T, b::T)::Edge{T} where T
    Edge{T}(⇿, (a, b), false)
end

# →  \rightarrow<tab>
"""
    →
"""
function →(a::T, b::T)::Edge{T} where T
    Edge{T}(→, (a, b), false)
end

# ←  \leftarrow<tab>
"""
    ←
"""
function ←(a::T, b::T)::Edge{T} where T
    Edge{T}(→, (b, a), true)
end

# ⇄  \rightleftarrows<tab>
"""
    ⇄
"""
function ⇄(a::T, b::T)::Edges{T} where T
    Edges([→(a, b), ←(a, b)], isunique=true)
end

# ⇆  \leftrightarrows<tab>
"""
    ⇆
"""
function ⇆(a::T, b::T)::Edges{T} where T
    Edges([←(a, b), →(a, b)], isunique=true)
end

function ⇄(a::T, edge::Edge{T})::Edges{T} where T
    Edges([⇄(a, nodeof(edge, first)).list..., edge])
end

function ⇆(a::T, edge::Edge{T})::Edges{T} where T
    Edges([⇆(a, nodeof(edge, first)).list..., edge])
end

for arrow in (:⇿, :→, :←)
    @eval function ($arrow)(a::T, edges::Edges{T})::Edges where T
        edge = first(edges.list)
        Edges([$arrow(a, nodeof(edge, first)), edges.list...])
    end

    @eval function ($arrow)(a::T, edge::Edge{T})::Edges where T
        Edges([$arrow(a, nodeof(edge, first)), edge])
    end

    @eval function ($arrow)(edge::Edge{T}, b::T)::Edges where T
        Edges([edge, $arrow(nodeof(edge, last), b)])
    end
end

"""
    union(args::Union{Edge{T}, Edges{T}}...)::Edges{T} where T
"""
function union(args::Union{Edge{T}, Edges{T}}...)::Edges{T} where T
    list = Vector{Edge{T}}()
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

function ==(a::Edge{T}, b::Edge{T}) where T
    if a.op === b.op === ⇿
        Set{T}(a.nodes) == Set{T}(b.nodes)
    else
        (a.op === b.op) && (a.nodes == b.nodes)
    end
end

function ==(l::Edges{T}, r::Edges{T}) where T
    length(l.list) == length(r.list) || return false
    a = Dict(((edge.op === ⇿) ? Set{T}(edge.nodes) : edge.nodes) => edge.op for edge in l.list)
    b = Dict(((edge.op === ⇿) ? Set{T}(edge.nodes) : edge.nodes) => edge.op for edge in r.list)
    a == b
end

function ==(l::Graph{T}, r::Graph{T}) where T
    l.nodes == r.nodes && l.edges == r.edges
end

function Base.iterate(edges::Edges{T}, state = 1) where T
    iterate(edges.list, state)
end

"""
    addedges(g::Graph{T}, edge::Edge{T})::Graph{T} where T
"""
function addedges(g::Graph{T}, edge::Edge{T})::Graph{T} where T
    addedges(g, Edges([edge], isunique=true))
end

"""
    addedges(g::Graph{T}, edges::Edges{T})::Graph{T} where T
"""
function addedges(g::Graph{T}, edges::Edges{T})::Graph{T} where T
    list = Vector{Edge{T}}(g.edges.list)
    nodes = Set{T}(g.nodes)
    @inbounds for edge in edges.list
        if !(edge in g.edges.list)
            push!(list, edge)
            push!(nodes, edge.nodes...)
        end
    end
    concatedges = Edges(list, isunique=true)
    Graph{T}(nodes, concatedges)
end

"""
    addedges!(callback, g::Graph{T}, edge::Edge{T}) where T
"""
function addedges!(callback, g::Graph{T}, edge::Edge{T}) where T
    addedges!(callback, g, Edges([edge], isunique=true))
end

"""
    addedges!(callback, g::Graph{T}, edges::Edges{T}) where T
"""
function addedges!(callback, g::Graph{T}, edges::Edges{T}) where T
    list = Vector{Edge{T}}()
    nodes = Set{T}()
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

"""
    cutedges(g::Graph{T}, edge::Edge{T})::Graph{T} where T
"""
function cutedges(g::Graph{T}, edge::Edge{T})::Graph{T} where T
    cutedges(g, Edges([edge], isunique=true))
end

"""
    cutedges(g::Graph{T}, edges::Edges{T})::Graph{T} where T
"""
function cutedges(g::Graph{T}, edges::Edges{T})::Graph{T} where T
    list = g.edges.list
    indices = filter(!isnothing, indexin(list, edges.list))
    Graph{T}(g.nodes, Edges(g.edges.list[setdiff(1:length(list), indices)], isunique=true))
end

"""
    cutedges!(callback, g::Graph{T}, edge::Edge{T}) where T
"""
function cutedges!(callback, g::Graph{T}, edge::Edge{T}) where T
    cutedges!(callback, g, Edges([edge], isunique=true))
end

"""
    cutedges!(callback, g::Graph{T}, edges::Edges{T}) where T
"""
function cutedges!(callback, g::Graph{T}, edges::Edges{T}) where T
    indices = filter(!isnothing, indexin(g.edges.list, edges.list))
    if length(g.edges.list) != length(indices)
        list = g.edges.list[indices]
        nodes = Set{T}()
        for edge in list
            push!(nodes, edge.nodes...)
        end
        deleteat!(g.edges.list, indices)
        callback(list, nodes)
    end
end

function allnodes(edges::Edges{T})::Vector{T} where T
    vcat(map(edge -> collect(edge.nodes), edges.list)...)
end

function Base.show(io::IO, mime::MIME"text/plain", graph::Graph{T}) where T
    print(io, nameof(Graph), "{", nameof(T), "}(")
    if graph.nodes isa Set{Node}
        Base.show(io, mime, graph.nodes)
    else
        print(io, "Set([")
        count = length(graph.nodes)
        @inbounds for (idx, node) in enumerate(graph.nodes)
            Base.show(io, mime, node)
            count != idx && print(io, ", ")
        end
        print(io, "])")
    end
    print(io, ", ")
    Base.show(io, mime, graph.edges)
    print(io, ")")
end

function Base.show(io::IO, mime::MIME"text/plain", edges::Edges{T}) where T
    count = length(edges.list)
    print(io, nameof(Edges), "{", nameof(T), "}([")
    @inbounds for (idx, edge) in enumerate(edges.list)
        Base.show(io, mime, edge)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

function Base.show(io::IO, mime::MIME"text/plain", edge::Edge{T}) where T
    ioctx = IOContext(io, :compact => true)
    if (edge.op === →) && edge.backward
        Base.show(ioctx, mime, last(edge.nodes))
        print(io, ' ', nameof(←), ' ')
        Base.show(ioctx, mime, first(edge.nodes))
    else
        Base.show(ioctx, mime, first(edge.nodes))
        print(io, ' ', nameof(edge.op), ' ')
        Base.show(ioctx, mime, last(edge.nodes))
    end
end

function Base.show(io::IO, mime::MIME"text/plain", node::Node)
    print(io, node.id)
end

function Base.show(io::IO, mime::MIME"text/plain", nodes::Set{Node})
    count = length(nodes)
    print(io, nameof(Set), "([")
    @inbounds for (idx, node) in enumerate(sort(collect(nodes)))
        Base.show(io, mime, node)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

# module Tutte.Graphs
