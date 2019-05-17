# module Tutte.Graphs

function push_edge(list::Vector{Edge{T}}, weights, e::Edge{ET}, prev::T) where {T, ET}
    weight = nodeof(e, first)
    second = nodeof(e, last)
    edge = Edge{T}(e.op, e.backward ? (second, prev) : (prev, second), e.backward)
    idx = indexin([edge], list)
    if [nothing] == idx
        push!(list, edge)
        push!(weights, weight)
    else
        weights[idx] .+= weight
    end
end

"""
    Weighted{T, WT}
"""
struct Weighted{T, WT} <: AbstractGraph{T}
    graph::Graph{T}
    weights::Vector{WT}

    function Weighted{T, WT}() where {T, WT}
        new{T, WT}(Graph{T}(), Vector{WT}())
    end

    function Weighted{T, WT}(args::Array{Any,2}...) where {T, WT}
        list = Vector{Edge{T}}()
        weights = Vector{WT}()
        @inbounds for arg in args
            prev = first(arg)
            for e in arg[2:end]
                if e isa Edges
                    for (idx, e2) in enumerate(e.list)
                        push_edge(list, weights, e2, prev)
                        if iseven(idx)
                            prev = nodeof(e2, last)
                        end
                    end
                elseif e isa Edge
                    push_edge(list, weights, e, prev)
                    prev = nodeof(e, last)
                end
            end
        end
        graph = Graph(Edges(list; isunique=true))
        new{T, WT}(graph, weights)
    end

    function Weighted(args::Array{Any,2}...)
        isempty(args) && throw(ArgumentError("Weighted isempty"))
        arg = first(args)
        T = typeof(first(arg))
        arg2 = arg[2]
        if arg2 isa Edge
            WT = typeof(nodeof(arg2, first))
        elseif arg2 isa Edges
            WT = typeof(nodeof(arg2.list[1], first))
        end
        Weighted{T, WT}(args...)
    end

    function Weighted{T, WT}(graph::Graph{T}, weights::Vector{WT}) where {T, WT}
        new{T, WT}(graph, weights)
    end

    function Weighted(graph::Graph{T}, weights::Vector{WT}) where {T, WT}
        Weighted{T, WT}(graph, weights)
    end
end # struct Weighted{T, WT}

function isempty(w::Weighted{T, WT}) where {T, WT}
    isempty(w.graph)
end

function ⇿(a::A, b::B)::Edge{Union{A,B}} where {A, B}
    Edge{Union{A,B}}(⇿, (a, b), false)
end

function →(a::A, b::B)::Edge{Union{A,B}} where {A, B}
    Edge{Union{A,B}}(→, (a, b), false)
end

function ←(a::A, b::B)::Edge{Union{A, B}} where {A, B}
    Edge{Union{A,B}}(→, (b, a), true)
end

function ⇄(a::A, b::B)::Edges{Union{A, B}} where {A, B}
    Edges([→(a, b), ←(a, b)], isunique=true)
end

function ⇆(a::A, b::B)::Edges{Union{A, B}} where {A, B}
    Edges([←(a, b), →(a, b)], isunique=true)
end

function ⇄(a::A, edge::Edge{B})::Edges{Union{A, B}} where {A, B}
    Edges([⇄(a, nodeof(edge, first)).list..., edge])
end

function ⇆(a::A, edge::Edge{B})::Edges{Union{A, B}} where {A, B}
    Edges([⇆(a, nodeof(edge, first)).list..., edge])
end

"""
    addedges!(callback, w::Weighted{T, WT}, arg::Array{Any, 2}) where {T, WT}
"""
function addedges!(callback, w::Weighted{T, WT}, arg::Array{Any, 2}) where {T, WT}
    edges = Vector{Edge{T}}()
    weights = Vector{WT}()
    nodes = Set{T}()
    x = Weighted{T, WT}(arg)
    for (edge, weight) in zip(x.graph.edges, x.weights)
        idx = indexin([edge], w.graph.edges.list)
        if [nothing] == idx
            push!(w.graph.edges.list, edge)
            push!(w.weights, weight)
            push!(w.graph.nodes, edge.nodes...)
            push!(edges, edge)
            push!(weights, weight)
            push!(nodes, edge.nodes...)
        else
            w.weights[idx] .+= weight
            c_idx = indexin([edge], edges)
            if [nothing] == c_idx
                push!(edges, edge)
                append!(weights, w.weights[idx])
                push!(nodes, edge.nodes...)
            else
                weights[c_idx] .= w.weights[idx]
            end
        end
    end
    callback(edges, weights, nodes)
end

"""
    cutedges!(callback, w::Weighted{T, WT}, edge::Edge{T}) where {T, WT}
"""
function cutedges!(callback, w::Weighted{T, WT}, edge::Edge{T}) where {T, WT}
    cutedges!(callback, w, Edges([edge], isunique=true))
end

"""
    cutedges!(callback, w::Weighted{T, WT}, edges::Edges{T}) where {T, WT}
"""
function cutedges!(callback, w::Weighted{T, WT}, edges::Edges{T}) where {T, WT}
    indices = filter(!isnothing, indexin(w.graph.edges.list, edges.list))
    if length(w.graph.edges.list) != length(indices)
        list = w.graph.edges.list[indices]
        weights = w.weights[indices]
        nodes = Set{T}()
        for edge in list
            push!(nodes, edge.nodes...)
        end
		deleteat!(w.graph.edges.list, indices)
        deleteat!(w.weights, indices)
        callback(list, weights, nodes)
    end
end

function is_directed(w::Weighted{T, WT}) where {T, WT}
    is_directed(w.graph)
end

function Base.show(io::IO, mime::MIME"text/plain", w::Weighted{T, WT}) where {T, WT}
    print(io, nameof(Weighted), "{", nameof(T), ",", " ", nameof(WT), "}(")
    Base.show(io, mime, w.graph)
    print(io, ", [")
    ioctx = IOContext(io, :compact => true)
    count = length(w.weights)
    @inbounds for (idx, weight) in enumerate(w.weights)
        Base.show(ioctx, mime, weight)
        count != idx && print(io, ", ")
    end
    print(io, "])")
end

# module Tutte.Graphs
