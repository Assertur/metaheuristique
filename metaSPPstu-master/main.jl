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
include("plotFunctions.jl")
using .SimpleDescent

# =========================================================================== #

# Loading a SPP instance

println("\nLoading...")
target = "Data"
fnames = getfname(target)
println("Filenames found: ", fnames)

tmoy = []                 # tableau des temps CPU
allfinstance = fnames     # tableau des noms pour le graphique CPU

for i in 1:length(fnames)
    println("Instance: ", fnames[i])
    C, A = loadSPP(joinpath("./Data/", fnames[i]))
    tstart = time()
    s1, z1 = construction(C, A, 1.0)
    println("Construction solution : ", z1, ", CpuT : ",time() - tstart)
    tstart = time()
    s2, z2 = SimpleDescent.updateZ(C, A, s1, z1)
    println("SimpleDescent solution : ", z2, ", CpuT : ",time() - tstart)

    tgrasp = time()
    zinit, zls, zbest, zbetter, s = simpleGrasp(A, C, 0.75, 100)
    t_elapsed = time() - tgrasp
    push!(tmoy, t_elapsed)
    println("Best z : ", zbetter, "CPU time = ", round(t_elapsed, digits=4), " s")
    plotRunGrasp(fnames[i], zinit, zls, zbest)
   
end

plotCPUt(allfinstance, tmoy)



# Solving a SPP instance with a reactive GRASP
#z2, s2 = reactiveGrasp(5,100,[0.1,0.25,0.5,0.75,0.9],C,A)

#println(pathRelinking(A, C, s1, z1, s2, z2))

#Solving with ACO
#println(ACO(1000, A, C, 50, 50))


# Solving a SPP instance with GLPK
#println("\nSolving...")
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
