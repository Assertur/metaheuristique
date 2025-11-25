using PyPlot

function plotRunGrasp(iname, zinit, zls, zbest, prefix="")
    # Function to plot the results of a run
    # Inputs: iname : instance name (string)
    #         zinit : vector of initial solution values at each iteration
    #         zls : vector of solution values after simple descent at each iteration
    #         zbest : vector of best solution values found up to each iteration
    #         prefix : prefix for the plot title and filename (string)

    plot_dir = "plots"
    isdir(plot_dir) || mkdir(plot_dir)

    last_valid = findlast(!=(0), zbest)
    zinit = zinit[1:last_valid]
    zls   = zls[1:last_valid]
    zbest = zbest[1:last_valid]

    figure(string(prefix,"run $iname"),figsize=(6,6)) # Create a new figure
    title("$prefix-spp | \$z_{Init}\$  \$z_{LS}\$  \$z_{Best}\$ | " * iname)
    xlabel("Itérations")
    ylabel("valeurs de z(x)")
    ylim(0, maximum(zbest)+2)

    nPoint = length(zinit)
    x=collect(1:nPoint)
    xticks([1,convert(Int64,ceil(nPoint/4)),convert(Int64,ceil(nPoint/2)), convert(Int64,ceil(nPoint/4*3)),nPoint])
    plot(x,zbest, linewidth=2.0, color="green", label="meilleures solutions")
    plot(x,zls,ls="",marker="^",ms=2,color="green",label="toutes solutions améliorées")
    plot(x,zinit,ls="",marker=".",ms=2,color="red",label="toutes solutions construites")
    vlines(x, zinit, zls, linewidth=0.5)
    legend(loc=4, fontsize ="small")

    filename = string(prefix, "_run_", iname, ".png")

    filepath = joinpath(plot_dir, filename)
    savefig(filepath)
    println("Plot sauvegardé dans $filepath")
    plt.close() 
end

function plotCPUt(allfinstance, tmoy, prefix="")
    # Function to plot the average CPU time over all runs
    # Inputs: allfinstance : list of instance names (vector of strings)
    #         tmoy : list of average CPU times per instance (vector of floats)
    #         prefix : prefix for the plot title and filename (string)

    plot_dir = "plots"
    isdir(plot_dir) || mkdir(plot_dir)

    figure("bilan CPUt tous runs $prefix",figsize=(6,10)) # Create a new figure
    title("GRASP-SPP | tMoy")
    ylabel("CPUt moyen (s)")

    xticks(collect(1:length(allfinstance)), allfinstance, rotation=60, ha="right")
    margins(0.15)
    subplots_adjust(bottom=0.15,left=0.21)
    plot(collect(1:length(allfinstance)),tmoy,linestyle="--", lw=0.5, marker="o", ms=4, color="blue", label="tMoy")
    legend(loc=4, fontsize ="small")

    filename = joinpath(plot_dir, "cput_$prefix.png")
    savefig(filename)
    println("Plot sauvegardé dans $filename")
    plt.close()
end
