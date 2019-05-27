module test_tutte_filter

using Test
using Tutte.Graphs

@nodes A B C D E

@test ⇿(C)(A) == ⇿(A)(C) == (A ⇿ C)
@test →(D)(C) == ←(C)(D) == (C → D) == (D ← C)
@test →(D) isa Base.Fix2{typeof(→), Node}
@test ←(C) isa Base.Fix2{typeof(←), Node}

edges = union(A ⇿ C → D, E → D)
@test filter(⇿(A), edges.list) == [A ⇿ C]
@test filter(⇿(C), edges.list) == [A ⇿ C]
@test filter(→(D), edges.list) == [C → D, D ←  E]
@test filter(←(C), edges).list == [C → D]

end # module test_tutte_filter
