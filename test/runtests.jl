using Jive
skips = ["tutte/modular_decomposition.jl"]
runtests(@__DIR__, skip=["profile.jl", skips...])
