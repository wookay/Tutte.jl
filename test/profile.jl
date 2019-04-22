include("tutte/graphs.jl")

using Profile
Profile.clear()

@profile include("tutte/graphs.jl")

using ProfileView
ProfileView.view()
