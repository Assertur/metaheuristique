function simpleGrasp(A,C,alpha,nbIter)
    # GRASP algorithm
    # Inputs: A : matrix of constraints 
    #         C : vector of costs
    #         alpha : parameter for greedy randomized construction (0 <= alpha <= 1)
    #         nbIter : number of iterations
    # Outputs: zconstruction : vector of initial solution values at each iteration
    #          zamelioration : vector of solution values after simple descent at each iteration
    #          zbest : vector of best solution values found up to each iteration
    #          zbetter : best solution value found

    zconstruction = zeros(Int64,nbIter)
    zamelioration = zeros(Int64,nbIter)
    zbest = zeros(Int64,nbIter)
    zbetter=0
    best_choices = []
    iter = 1
    while iter <= nbIter 
        #Greedy construction heuristic
        choices, z = construction(C, A, alpha)
        zconstruction[iter] = z
        #Simple descent heuristic
        choices, z = SimpleDescent.updateZ(C, A, choices, z)
        zamelioration[iter] = z
        if z > zbetter
            zbetter = z
            best_choices = choices
        end
        zbest[iter] = zbetter
        iter += 1
    end
    return zconstruction, zamelioration, zbest, zbetter, best_choices
end