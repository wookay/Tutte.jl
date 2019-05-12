# module Tutte.Graphs

struct Weighted
    graph::Graph
    weights::Vector
    function Weighted(args::Array{Any,2}...)
        isempty(args) && return new(Graph(), [])
        list = Vector{Edge}()
        weights = []
        @inbounds for arg in args
            prev = first(arg)
            for e in arg[2:end]
                weight = e.nodes[1]
                edge = Edge(e.op, (prev, e.nodes[2]), e.backward)
                idx = indexin([edge], list)
                if [nothing] == idx
                    push!(list, edge)
                    push!(weights, weight)
                else
                    weights[idx] .+= weight
                end
                prev = edge.nodes[2]
            end
        end
        graph = Graph(Edges(list; isunique=true))
        new(graph, weights)
    end
end

# module Tutte.Graphs
