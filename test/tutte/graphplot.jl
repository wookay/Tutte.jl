module test_tutte_graphplot

using Test
using Tutte.Graphs # Graph ⇿ @nodes
using LightGraphs.SimpleGraphs: SimpleGraph
using GraphPlot: spring_layout, graphline

@nodes A B C D E
graph = Graph(A ⇿ C ⇿ D ⇿ E)
g = SimpleGraph(graph)
locs_x, locs_y = spring_layout(g; seed=2017)
lines_cord = graphline(g, locs_x, locs_y, 1)
@test lines_cord[1][1][1] ≈ -0.2928932188134511

end
