# module Tutte.Graphs

using LightGraphs: AbstractGraph, AbstractEdge
using Base: Fix2

"""
    WTNode
"""
struct WTNode
    id::Symbol
end

"""
    WTEdge{T}
"""
struct WTEdge{T} <: AbstractEdge{T}
    op::Function
    nodes::Tuple{T, T}
    backward::Bool
end

"""
    WTEdges{T}
"""
struct WTEdges{T}
    list::Vector{WTEdge{T}}

    # WTEdges{WTNode}([])
    function WTEdges{T}(list::Vector{Any}) where T
        new{T}(list)
    end

    function WTEdges{T}(list::Vector{WTEdge{T}}; isunique=false) where T
        if isunique
            new{T}(list)
        else
            edges = Vector{WTEdge{T}}()
            @inbounds for edge in list
                !(edge in edges) && push!(edges, edge)
            end
            new{T}(edges)
        end
    end

    function WTEdges(list::Vector{WTEdge{T}}; isunique=false) where T
        WTEdges{T}(list; isunique=isunique)
    end
end # struct WTEdges{T}

"""
    WTGraph{T}
"""
struct WTGraph{T} <: AbstractGraph{T}
    nodes::Set{T}
    edges::WTEdges{T}

    function WTGraph{T}(nodes::Set{T}, edges::WTEdges{T}) where T
        new{T}(nodes, edges)
    end

    function WTGraph{T}(edges::WTEdges{T}) where T
        WTGraph{T}(allnodes(edges), edges)
    end

    function WTGraph{T}(edge::WTEdge{T}) where T
        WTGraph{T}(WTEdges([edge]; isunique=true))
    end

    function WTGraph{T}() where T
        WTGraph{T}(Set{T}(), WTEdges(Vector{WTEdge{T}}(), isunique=true))
    end

    function WTGraph(nodes::Set{T}, edges::WTEdges{T}) where T
        WTGraph{T}(nodes, edges)
    end

    function WTGraph(edges::WTEdges{T}) where T
        WTGraph{T}(edges)
    end

    function WTGraph(edge::WTEdge{T}) where T
        WTGraph{T}(WTEdges([edge]; isunique=true))
    end

end # struct WTGraph{T} <: AbstractGraph{T}

"""
    @nodes
"""
macro nodes(args...)
    esc(graph_nodes(args))
end

function graph_nodes(s)
    :(($(s...),) = $(map(id -> WTNode(id), s)))
end

function Base.isempty(g::WTGraph{T}) where T
    isempty(g.nodes) && isempty(g.edges)
end

function Base.isempty(edges::WTEdges{T}) where T
    isempty(edges.list)
end

# ⇿  \leftrightarrowtriangle<tab>
"""
    ⇿
"""
function ⇿(a::T, b::T)::WTEdge{T} where T
    WTEdge{T}(⇿, (a, b), false)
end

# →  \rightarrow<tab>
"""
    →
"""
function →(a::T, b::T)::WTEdge{T} where T
    WTEdge{T}(→, (a, b), false)
end

# ←  \leftarrow<tab>
"""
    ←
"""
function ←(a::T, b::T)::WTEdge{T} where T
    WTEdge{T}(→, (b, a), true)
end

# ⇄  \rightleftarrows<tab>
"""
    ⇄
"""
function ⇄(a::T, b::T)::WTEdges{T} where T
    WTEdges([→(a, b), ←(a, b)], isunique=true)
end

# ⇆  \leftrightarrows<tab>
"""
    ⇆
"""
function ⇆(a::T, b::T)::WTEdges{T} where T
    WTEdges([←(a, b), →(a, b)], isunique=true)
end

function ⇄(a::T, edge::WTEdge{T})::WTEdges{T} where T
    WTEdges([⇄(a, nodeof(edge, first)).list..., edge])
end

function ⇆(a::T, edge::WTEdge{T})::WTEdges{T} where T
    WTEdges([⇆(a, nodeof(edge, first)).list..., edge])
end

for arrow in (:⇿, :→, :←)
    @eval function ($arrow)(a::T, edges::WTEdges{T})::WTEdges where T
        edge = first(edges.list)
        WTEdges([$arrow(a, nodeof(edge, first)), edges.list...])
    end

    @eval function ($arrow)(a::T, edge::WTEdge{T})::WTEdges where T
        WTEdges([$arrow(a, nodeof(edge, first)), edge])
    end

    @eval function ($arrow)(edge::WTEdge{T}, b::T)::WTEdges where T
        WTEdges([edge, $arrow(nodeof(edge, last), b)])
    end
end

is_directed(::typeof(⇿)) = false
is_directed(::typeof(→)) = true
is_directed(::typeof(←)) = true
inverse(::typeof(⇿)) = ⇿
inverse(::typeof(→)) = ←
inverse(::typeof(←)) = →

function is_directed(edge::WTEdge{T}) where T
    is_directed(edge.op)
end

function is_directed(edges::WTEdges{T}) where T
    isempty(edges) && return false
    @inbounds for edge in edges.list
        !is_directed(edge) && return false
    end
    true
end

function is_directed(g::WTGraph{T}) where T
    is_directed(g.edges)
end

"""
    union(args::Union{WTEdge{T}, WTEdges{T}}...)::WTEdges{T} where T
"""
function Base.union(args::Union{WTEdge{T}, WTEdges{T}}...)::WTEdges{T} where T
    list = Vector{WTEdge{T}}()
    @inbounds for arg in args
        if arg isa WTEdge
            !(arg in list) && push!(list, arg)
        elseif arg isa WTEdges
            for edge in arg.list
                !(edge in list) && push!(list, edge)
            end
        end
    end
    WTEdges(list, isunique=true)
end

function Base.:(==)(a::WTEdge{T}, b::WTEdge{T}) where T
    if a.op === b.op
        if is_directed(a.op)
            a.nodes == b.nodes
        else
            Set{T}(a.nodes) == Set{T}(b.nodes)
        end
    else
        false
    end
end

function Base.:(==)(l::WTEdges{T}, r::WTEdges{T}) where T
    length(l.list) == length(r.list) || return false
    a = Dict((is_directed(edge.op) ? edge.nodes : Set{T}(edge.nodes)) => edge.op for edge in l.list)
    b = Dict((is_directed(edge.op) ? edge.nodes : Set{T}(edge.nodes)) => edge.op for edge in r.list)
    a == b
end

function Base.:(==)(l::WTGraph{T}, r::WTGraph{T}) where T
    l.nodes == r.nodes && l.edges == r.edges
end

function Base.iterate(edges::WTEdges{T}, state = 1) where T
    iterate(edges.list, state)
end

function Base.length(edges::WTEdges{T}) where T
    length(edges.list)
end

function Base.push!(edges::WTEdges{T}, edge::WTEdge{T}) where T
    push!(edges.list, edge)
end

function Base.empty(::WTEdges{T}) where T
    WTEdges{T}([])
end

function Base.empty!(edges::WTEdges{T}) where T
    empty!(edges.list)
end

"""
    add_edges(g::WTGraph{T}, edge::WTEdge{T})::WTGraph{T} where T
"""
function add_edges(g::WTGraph{T}, edge::WTEdge{T})::WTGraph{T} where T
    add_edges(g, WTEdges([edge], isunique=true))
end

"""
    add_edges(g::WTGraph{T}, edges::WTEdges{T})::WTGraph{T} where T
"""
function add_edges(g::WTGraph{T}, edges::WTEdges{T})::WTGraph{T} where T
    list = Vector{WTEdge{T}}(g.edges.list)
    nodes = Set{T}(g.nodes)
    @inbounds for edge in edges.list
        if !(edge in g.edges.list)
            push!(list, edge)
            push!(nodes, edge.nodes...)
        end
    end
    concatedges = WTEdges(list, isunique=true)
    WTGraph{T}(nodes, concatedges)
end

"""
    add_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
"""
function add_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
    add_edges!(callback, g, WTEdges([edge], isunique=true))
end

"""
    add_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
"""
function add_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
    list = Vector{WTEdge{T}}()
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
    remove_edges(g::WTGraph{T}, edge::WTEdge{T})::WTGraph{T} where T
"""
function remove_edges(g::WTGraph{T}, edge::WTEdge{T})::WTGraph{T} where T
    remove_edges(g, WTEdges([edge], isunique=true))
end

"""
    remove_edges(g::WTGraph{T}, edges::WTEdges{T})::WTGraph{T} where T
"""
function remove_edges(g::WTGraph{T}, edges::WTEdges{T})::WTGraph{T} where T
    list = g.edges.list
    indices = filter(!isnothing, indexin(list, edges.list))
    WTGraph{T}(g.nodes, WTEdges(g.edges.list[setdiff(1:length(list), indices)], isunique=true))
end

"""
    remove_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
"""
function remove_edges!(callback, g::WTGraph{T}, edge::WTEdge{T}) where T
    remove_edges!(callback, g, WTEdges([edge], isunique=true))
end

"""
    remove_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
"""
function remove_edges!(callback, g::WTGraph{T}, edges::WTEdges{T}) where T
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

function Base.isless(a::WTNode, b::WTNode)
    a.id < b.id
end

function nodeof(edge::WTEdge{T}, ::typeof(first)) where T
    edge.backward ? edge.nodes[2] : edge.nodes[1]
end

function nodeof(edge::WTEdge{T}, ::typeof(last)) where T
    edge.backward ? edge.nodes[1] : edge.nodes[2]
end

function allnodes(edges::WTEdges{T})::Set{T} where T
    Set{T}(vcat(map(edge -> collect(edge.nodes), edges.list)...))
end

function Base.show(io::IO, mime::MIME"text/plain", graph::WTGraph{T}) where T
    print(io, nameof(WTGraph), "{", nameof(T), "}(")
    if graph.nodes isa Set{WTNode}
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

function Base.show(io::IO, mime::MIME"text/plain", edges::WTEdges{T}) where T
    count = length(edges.list)
    print(io, nameof(WTEdges), "{", nameof(T), "}([")
    @inbounds for (idx, edge) in enumerate(edges.list)
        Base.show(io, mime, edge)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

function Base.show(io::IO, mime::MIME"text/plain", edge::WTEdge{T}) where T
    if edge.backward
        op, l, r = inverse(edge.op), last, first
    else
        op, l, r = edge.op, first, last
    end
    ioctx = IOContext(io, :compact => true)
    Base.show(ioctx, mime, l(edge.nodes))
    print(io, ' ', nameof(op), ' ')
    Base.show(ioctx, mime, r(edge.nodes))
end

function Base.show(io::IO, mime::MIME"text/plain", node::WTNode)
    print(io, node.id)
end

function Base.show(io::IO, mime::MIME"text/plain", nodes::Set{WTNode})
    count = length(nodes)
    print(io, nameof(Set), "([")
    @inbounds for (idx, node) in enumerate(sort(collect(nodes)))
        Base.show(io, mime, node)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

⇿(node::T) where T = Fix2(⇿, node)
→(node::T) where T = Fix2(→, node)
←(node::T) where T = Fix2(←, node)

function mapfilter(pred, f, itr::Vector{WTEdge{T}}, res::Vector{WTEdge{T}}) where T
    @inbounds for edge in itr
        if is_directed(pred.f)
            if pred.f === edge.op
                node = first(edge.nodes)
            else
                node = last(edge.nodes)
            end
            pred(node) == edge && f(res, edge)
        else
            for node in edge.nodes
                if pred(node) == edge
                    f(res, edge)
                    break
                end
            end
        end
    end
    res
end

function Base.filter(f::Fix2, list::Vector{WTEdge{T}}) where T
    mapfilter(f, push!, list, empty(list))
end

function Base.filter(f::Fix2, edges::WTEdges{T}) where T
    WTEdges{T}(mapfilter(f, push!, edges.list, empty(edges.list)))
end

function Base.replace(graph::WTGraph{GT}, vertices::Vector{T})::WTGraph{T} where {GT, T}
    sortednodes = sort(collect(graph.nodes))
    list = [WTEdge{T}(edge.op, tuple(vertices[indexin(edge.nodes, sortednodes)]...), edge.backward) for edge in graph.edges.list]
    WTGraph{T}(Set{T}(vertices), WTEdges{T}(list))
end

function Base.replace(graph::WTGraph{T}, pairs::Pair{T, T}...)::WTGraph{T} where T
    nodes = replace(graph.nodes, pairs...)
    WTGraph{T}(nodes, replace(graph.edges, pairs...))
end

function Base.replace(edges::WTEdges{T}, pairs::Pair{T, T}...)::WTEdges{T} where T
    list = [WTEdge{T}(edge.op, tuple(replace(collect(edge.nodes), pairs...)...), edge.backward) for edge in edges.list]
    WTEdges{T}(list)
end

# module Tutte.Graphs
