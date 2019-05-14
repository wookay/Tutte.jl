using Tutte
using .Tutte: Graphs
using Documenter

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [Tutte],
    clean = false,
    format = Documenter.HTML(),
    sitename = "Tutte.jl ፨",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
    ],
)
