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
fname = "./Data/pb_100rnd0100.dat"
C, A = loadSPP(fname)
@show C
@show A

#Greedy construction heuristic
println("\nConstructing...")
choices, z = construction(C, A) 
println("z = ", z)
print("x = "); println(choices)

#Simple descent heuristic
println("\nImproving...")
for i in 1:20
    new_choices, new_z = kpExchange(C, A, choices, z, 2, 2)
    if new_z > z
        global choices, z
        choices = new_choices
        z = new_z
        println("z = ", z)
        print("x = "); println(choices)
        println(i)
    end
end
for i in 1:15
    new_choices, new_z = kpExchange(C, A, choices, z, 1, 1)
    if new_z > z
        global choices, z
        choices = new_choices
        z = new_z
        println("z = ", z)
        print("x = "); println(choices)
        println(i)
    end
end
for i in 1:10
    new_choices, new_z = kpExchange(C, A, choices, z, 0, 1)
    if new_z > z
        global choices, z
        choices = new_choices
        z = new_z
        println("z = ", z)
        print("x = "); println(choices)
        println(i)
    end
end

# Solving a SPP instance with GLPK
println("\nSolving...")
solverSelected = GLPK.Optimizer
spp = setSPP(C, A)

set_optimizer(spp, solverSelected)
optimize!(spp)

# Displaying the results
println("z = ", objective_value(spp))
print("x = "); println(value.(spp[:x]))

# =========================================================================== #

# Collecting the names of instances to solve
println("\nCollecting...")
target = "Data"
fnames = getfname(target)

println("\nThat's all folks !")
