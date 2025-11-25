function reactiveGrasp(itp, itg, listK, C, A)
    # Reactive GRASP algorithm
    # Inputs: itp : number of iterations per parameter value
    #         itg : total number of iterations
    #         listK : list of alpha parameter values
    #         C : vector of costs
    #         A : matrix of constraints
    # Outputs: zBetter : best solution value found
    #          cBest : best solution found (vector of choices)
    #          zAvgK : average solution values per parameter value
    #          zWorst : worst solution value found
    #          zconstruction : vector of initial solution values at each iteration
    #          zamelioration : vector of solution values after simple descent at each iteration
    #          zbest : vector of best solution values found up to each iteration

    zAvgK = zeros(Float64, size(listK,1))
    pK = fill(1/size(listK,1), size(listK,1))
    qk = zeros(Float64, size(listK,1))
    itk = zeros(Integer, size(listK,1))

    zconstruction = []
    zamelioration = []
    zbest=[]

    zWorst = Inf
    zBetter = 0
    cBest = []
    n = itg / itp
    for i in 1:n 
        for j in 1:itp
            r = rand()
            temp = 0
            k = 0
            while r > temp
                k += 1
                temp += pK[k]
            end
            alpha = listK[k]
            choices, z = construction(C, A, alpha)
            push!(zconstruction, z)
            choices, z = SimpleDescent.updateZ(C, A, choices, z)
            push!(zamelioration, z)
            zAvgK[k] = (zAvgK[k] * itk[k] + z) / (itk[k] + 1)
            itk[k] += 1
            if z < zWorst
                zWorst = z
            end
            if z > zBetter
                zBetter = z
                cBest = copy(choices)
            end
            push!(zbest, zBetter)
        end
        qi = 0
        for i in 1:size(listK,1)
            qk[i] = (zAvgK[i] - zWorst) / (zBetter - zWorst) 
            qi += qk[i]
        end
        for i in 1:size(listK,1)
            pK[i] = qk[i] / qi
        end
    end
    return zBetter, cBest, zAvgK, zWorst, zconstruction, zamelioration, zbest
end
