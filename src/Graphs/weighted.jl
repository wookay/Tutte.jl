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

struct Weighted{T}
    graph::Graph{T}
    weights::Vector

    function Weighted{T}() where T
        new{T}(Graph{T}(), [])
    end

    function Weighted{T}(args::Array{Any,2}...) where T
        list = Vector{Edge{T}}()
        weights = []
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
        new{T}(graph, weights)
    end

    function Weighted(args::Array{Any,2}...)
        isempty(args) && throw(ArgumentError("Weighted isempty"))
        T = typeof(first(first(args)))
        Weighted{T}(args...)
    end
end # struct Weighted{T}

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

function addedges!(callback, w::Weighted{T}, arg::Array{Any, 2}) where T
    edges = Vector{Edge{T}}()
    weights = []
    nodes = Set{T}()
    x = Weighted{T}(arg)
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

function cutedges!(callback, w::Weighted{T}, edge::Edge{T}) where T
    cutedges!(callback, w, Edges([edge], isunique=true))
end

function cutedges!(callback, w::Weighted{T}, edges::Edges{T}) where T
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

# module Tutte.Graphs
