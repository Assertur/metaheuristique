#!/usr/bin/env julia
# =========================================================================== #
# Compliant Julia 1.x
# =========================================================================== #

using JuMP, GLPK
using LinearAlgebra
using ArgParse

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
# ACO parameters per instance
aco_param = Dict(
    "didactic.dat"       => [10, 40, 3, 0.02, 0.10],
    "pb_100rnd0100.dat"  => [10, 40, 3, 0.02, 0.10],
    "pb_100rnd0300.dat"  => [12, 50, 4, 0.015, 0.08],
    "pb_200rnd0100.dat"  => [12, 40, 3, 0.02, 0.10],
    "pb_200rnd0300.dat"  => [10, 40, 2, 0.03, 0.12],
    "pb_500rnd0100.dat"  => [15, 30, 3, 0.015, 0.08],
    "pb_500rnd0400.dat"  => [20, 40, 5, 0.01, 0.1],
    "pb_1000rnd0100.dat" => [20, 40, 5, 0.01, 0.05],
    "pb_1000rnd0300.dat" => [10, 25, 2, 0.03, 0.12],
    "pb_2000rnd0100.dat" => [25, 25, 5, 0.008, 0.04],
    "pb_2000rnd0500.dat" => [20, 30, 4, 0.012, 0.06]
)

# =========================================================================== #
# Function to run a single instance with selected method(s)
function run_instance(instance, method="all", plot=true)
    println("\nInstance: $instance")
    C, A = loadSPP(joinpath("./Data/", instance))

    # Construction + Simple Descent
    if method == "greedy"
        println("\nSolving with greedy construction + simple descent...")
        
        tstart = time()
        s1, z1 = construction(C, A, 1.0)
        println("Construction solution : $z1, CpuT : ", round(time() - tstart, digits=4))

        tstart = time()
        s2, z2 = SimpleDescent.updateZ(C, A, s1, z1)
        println("SimpleDescent solution : $z2, CpuT : ", round(time() - tstart, digits=4))
    end

    # Simple GRASP
    if method in ["grasp", "pr", "all"]
        println("\nSolving with simple GRASP...")
        tgrasp = time()
        zinit_grasp, zls_grasp, zbest_grasp, zbetter_grasp, s_grasp = simpleGrasp(A, C, 0.75, 100)
        t_elapsed = time() - tgrasp
        println("Best z : $zbetter_grasp, CPU time = ", round(t_elapsed, digits=4), " s")
        if plot
            plotRunGrasp(instance, zinit_grasp, zls_grasp, zbest_grasp, "grasp")
        end
    end

    # Reactive GRASP
    if method in ["reactive", "pr", "all"]
        println("\nSolving with reactive GRASP...")
        treactive = time()
        zbetter_reactive, s_reactive, zAvgK, zWorst, zinit_reactive, zls_reactive, zbest_reactive = reactiveGrasp(5,200,[0.1,0.25,0.5,0.75,0.9],C,A)
        t_elapsed = time() - treactive
        println("Best z : $zbetter_reactive, Avg Z : $zAvgK, Worst z : $zWorst, CPU time = ", round(t_elapsed,digits=4)," s")
        if plot
            plotRunGrasp(instance, zinit_reactive, zls_reactive, zbest_reactive, "reactive")
        end
    end

    # Path Relinking
    if method in ["pr", "all"]
        println("\nSolving with Path Relinking...")
        tpr = time()
        s3 , zbetter_pr = pathRelinking(A, C, s_grasp, zbetter_grasp, s_reactive, zbetter_reactive)
        t_elapsed = time() - tpr
        println("Best z : $zbetter_pr, CPU time = ", round(t_elapsed,digits=4), " s")
    end

    # ACO
    if method in ["aco", "all"]
        println("\nSolving with ACO...")
        taco = time()
        params = aco_param[instance]
        zbetter_aco, zinit_aco, zls_aco, zbest_aco = ACO(A, C, params[1], params[2], params[3], params[4], params[5])
        t_elapsed = time() - taco
        println("Best z : $zbetter_aco, CPU time = ", round(t_elapsed,digits=4), " s")
        if plot
            plotRunGrasp(instance, zinit_aco, zls_aco, zbest_aco, "aco")
        end
    end

    if method in ["mip"]
        println("\nSolving...")
        solverSelected = GLPK.Optimizer
        spp = setSPP(C, A)

        set_optimizer(spp, solverSelected)
        optimize!(spp)

        # Displaying the results
        println("z = ", objective_value(spp))
        print("x = "); println(value.(spp[:x]))
    end

end

# =========================================================================== #
# Main function
function main()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--method"
        help = "Method to run: greedy / grasp / reactive / pr / aco / all"
        default = "all"
        arg_type = String

        "--instance", "-i"
            help = "Filename in ./Data/"
            arg_type = String
            default = "all"

        "--plot"
        help = "Generate plots"
        action = :store_true
    end

    parsed_args = parse_args(s)
    method = lowercase(parsed_args["method"])
    instance = parsed_args["instance"]
    do_plot = get(parsed_args, "plot", false)


    if instance != "all"
        run_instance(instance, method, do_plot)
    else
        fnames = getfname("Data")
        for f in fnames
            run_instance(f, method, do_plot)
        end
    end
    println("\nThat's all folks !")
end

# =========================================================================== #
# Launch main
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
