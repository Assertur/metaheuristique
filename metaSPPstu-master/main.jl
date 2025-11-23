# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("construction.jl")
include("feasible.jl")
include("simpleDescent.jl")
include("simpleGrasp.jl")
include("reactiveGrasp.jl")
include("pathRelinking.jl")
include("ACO.jl")
using .SimpleDescent

# =========================================================================== #

# Loading a SPP instance
println("\nLoading...")
fname = "./Data/pb_1000rnd0100.dat"
C, A = loadSPP(fname)
#@show C
#@show A

# Solving a SPP instance with a simple GRASP
z1, s1 = simpleGrasp(A,C,0.75)

# Solving a SPP instance with a reactive GRASP
z2, s2 = reactiveGrasp(5,100,[0.1,0.25,0.5,0.75,0.9],C,A)

#println(pathRelinking(A, C, s1, z1, s2, z2))

#Solving with ACO
println(ACO(1000, A, C, 50, 50))


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
