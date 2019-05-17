module seizure_model

using Simulation73, HodgkinHuxleyModel

export get_example
export plot_and_save

include("examples.jl")
include("analysis.jl")

end # module
