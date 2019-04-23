module test_tutte_graphplot

using Test
using Tutte.Graphs # Graph ⇿ IDMap Node @nodes
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, edges, src, dst
using GraphPlot # spring_layout

@nodes A B C D E
graph = Graph(A ⇿ C ⇿ D ⇿ E)
idmap = IDMap(graph)
g = SimpleGraph(graph)
locs_x, locs_y = spring_layout(g; seed=2017)

points = []
nodesize = 1
rounded(x) = round(x, digits=2)
for (e_idx, e) in enumerate(edges(g))
    i = src(e)
    j = dst(e)
    Δx = locs_x[j] - locs_x[i]
    Δy = locs_y[j] - locs_y[i]
    d  = sqrt(Δx^2 + Δy^2)
    θ  = atan(Δy,Δx)
    startx = locs_x[i] + nodesize*cos(θ)
    starty = locs_y[i] + nodesize*sin(θ)
    endx   = locs_x[i] + (d-nodesize)*1.00*cos(θ)
    endy   = locs_y[i] + (d-nodesize)*1.00*sin(θ)
    push!(points, (from=rounded.((startx, starty)), to=rounded.((endx, endy)), edge=(idmap[i], idmap[j])))
end

@test points == [(from = (-0.29, 0.29), to = (-1.06, 1.06), edge = (Node(:A), Node(:C))),
                 (from = (0.35, -0.35), to = (-0.35, 0.35), edge = (Node(:C), Node(:D))),
                 (from = (1.06, -1.06), to = (0.29, -0.29), edge = (Node(:D), Node(:E)))]

end
