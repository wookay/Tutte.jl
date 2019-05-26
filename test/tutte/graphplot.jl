module test_tutte_graphplot

using Test
using Tutte.Graphs # Graph ⇿ @nodes
using Tutte.Graphs: simplegraph_nodes
using LightGraphs.SimpleGraphs: SimpleGraph
using GraphPlot: spring_layout, graphline

@nodes A B C D E
graph = Graph(A ⇿ C ⇿ D ⇿ E)
g, nodes = simplegraph_nodes(graph)
locs_x, locs_y = spring_layout(g)
lines_cord = graphline(g, locs_x, locs_y, 1)
@test lines_cord[1][1][1] isa Number

end # module test_tutte_graphplot
