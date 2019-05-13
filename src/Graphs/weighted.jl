# module Tutte.Graphs

struct Weighted
    graph::Graph
    weights::Vector
    function Weighted(args::Array{Any,2}...)
        isempty(args) && return new(Graph(), [])
        list = Vector{Edge}()
        weights = []
        function push_edge(e::Edge, prev)
            weight = nodeof(e, first)
            second = nodeof(e, last)
            edge = Edge(e.op, e.backward ? (second, prev) : (prev, second), e.backward)
            idx = indexin([edge], list)
            if [nothing] == idx
                push!(list, edge)
                push!(weights, weight)
            else
                weights[idx] .+= weight
            end
        end
        @inbounds for arg in args
            prev = first(arg)
            for e in arg[2:end]
                if e isa Edges
                    for (idx, e2) in enumerate(e.list)
                        push_edge(e2, prev)
                        if iseven(idx)
                            prev = nodeof(e2, last)
                        end
                    end
                elseif e isa Edge
                    push_edge(e, prev)
                    prev = nodeof(e, last)
                end
            end
        end
        graph = Graph(Edges(list; isunique=true))
        new(graph, weights)
    end
end

# module Tutte.Graphs
