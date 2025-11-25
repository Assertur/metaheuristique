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
tmoy2 = []                # tableau des temps CPU pour reactive GRASP
tmoy3 = []                # tableau des temps CPU pour Path Relinking
tmoy4 = []                # tableau des temps CPU pour ACO

for i in 1:length(fnames)
    println("Instance: ", fnames[i])
    C, A = loadSPP(joinpath("./Data/", fnames[i]))
    tstart = time()
    s1, z1 = construction(C, A, 1.0)
    println("Construction solution : ", z1, ", CpuT : ",time() - tstart)
    tstart = time()
    s2, z2 = SimpleDescent.updateZ(C, A, s1, z1)
    println("SimpleDescent solution : ", z2, ", CpuT : ",time() - tstart)

    # Solving a SPP instance with a simple GRASP
    println("\nSolving with simple GRASP...")
    tgrasp = time()
    zinit_grasp, zls_grasp, zbest_grasp, zbetter_grasp, s_grasp = simpleGrasp(A, C, 0.75, 100)
    t_elapsed = time() - tgrasp
    push!(tmoy, t_elapsed)
    println("Best z : ", zbetter_grasp, ", CPU time = ", round(t_elapsed, digits=4), " s")
    plotRunGrasp(fnames[i], zinit_grasp, zls_grasp, zbest_grasp, "grasp")

    #Solving a SPP instance with a reactive GRASP
    treactive = time()
    println("\nSolving with reactive GRASP...")
    zbetter_reactive, s_reactive, zAvgK, zWorst, zinit_reactive, zls_reactive, zbest_reactive  = reactiveGrasp(5,200,[0.1,0.25,0.5,0.75,0.9],C,A)
    t_elapsed = time() - treactive
    push!(tmoy2, t_elapsed)
    println("Best z : ", zbetter_reactive, ", Avg Z : ", zAvgK , ", Worst z : ", zWorst , ", CPU time = ", round(t_elapsed, digits=4), " s")
    plotRunGrasp(fnames[i], zinit_reactive, zls_reactive, zbest_reactive, "reactive")

    tpr = time()
    println("\nSolving with Path Relinking...")
    s3 , zbetter_pr = pathRelinking(A, C, s_grasp, zbetter_grasp, s_reactive, zbetter_reactive)
    t_elapsed = time() - tpr
    push!(tmoy3, t_elapsed)
    println("Best z : ", zbetter_pr, ", CPU time = ", round(t_elapsed, digits=4), " s")

    #Solving with ACO
    println("\nSolving with ACO...")
    taco = time()
    zbetter_aco, zinit_aco, zls_aco, zbest_aco = ACO(A, C)
    t_elapsed = time() - taco
    push!(tmoy4, t_elapsed)
    plotRunGrasp(fnames[i], zinit_aco, zls_aco, zbest_aco, "aco")
    println("Best z : ", zbetter_aco, ", CPU time = ", round(t_elapsed, digits=4), " s")
end

plotCPUt(allfinstance, tmoy, "grasp")
plotCPUt(allfinstance, tmoy2, "reactivegrasp")
plotCPUt(allfinstance, tmoy3, "pathrelinking")
plotCPUt(allfinstance, tmoy4, "aco")







"""
fname="Data/pb_100rnd0300.dat"
C, A = loadSPP(fname)

# Solving a SPP instance with GLPK
println("\nSolving...")
solverSelected = GLPK.Optimizer
spp = setSPP(C, A)

set_optimizer(spp, solverSelected)
optimize!(spp)

# Displaying the results
println("z = ", objective_value(spp))
print("x = "); println(value.(spp[:x]))"""

println("\nThat's all folks !")
