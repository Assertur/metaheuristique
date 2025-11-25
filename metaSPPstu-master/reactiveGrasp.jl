function reactiveGrasp(itp, itg, listK, C, A)
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
