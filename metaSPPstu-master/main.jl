# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("construction.jl")
include("simpleDescent.jl")
using .SimpleDescent

# =========================================================================== #

# Loading a SPP instance
println("\nLoading...")
fname = "./Data/pb_500rnd0100.dat"
C, A = loadSPP(fname)
#@show C
#@show A

timer_start = time()
#Greedy construction heuristic
println("\nConstructing...")
choices, z = construction(C, A, 0.75) 
println("z = ", z)
#print("x = "); println(choices)
println("Time taken for construction: ", time() - timer_start, " seconds")

timer_start = time()
#Simple descent heuristic
println("\nImproving...")
choices, z = SimpleDescent.updateZ(C, A, choices, z)
println("z = ", z)
println("Time taken for construction: ", time() - timer_start, " seconds")

# Solving a SPP instance with GLPK
println("\nSolving...")
#solverSelected = GLPK.Optimizer
#spp = setSPP(C, A)

#set_optimizer(spp, solverSelected)
#optimize!(spp)

# Displaying the results
#println("z = ", objective_value(spp))
#print("x = "); println(value.(spp[:x]))

# =========================================================================== #

# Collecting the names of instances to solve
println("\nCollecting...")
target = "Data"
fnames = getfname(target)

println("\nThat's all folks !")
