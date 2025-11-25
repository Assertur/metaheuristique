mutable struct Ant
    value
    z
    feasible
    mp
end

clamp01(x) = clamp(x, 0.0, 1.0)

function generatePopulation(n, C, A)
    #Create a population of n ant
    pop = []
    for i in 1:n 
        ant = Ant(zeros(size(C,1)), 0, true, zeros(size(A,1)))
        push!(pop,ant)
    end
    return pop
end


function managePheromones!(phi, bestSolKnown, bestSolIter, rhoE = 0.1, rhoD = 0.1, iter = 1, maxIter = 100,iterStagnant = 50, lastImprovedIterRef = 0)
    m = length(phi)
    for i in 1:m
        phi[i] = phi[i] * (1.0 - rhoE)
    end
    for i in 1:m
        if bestSolIter[i] == 1
            phi[i] += rhoD
        end
    end
    for i in 1:m
        phi[i] = clamp01(phi[i])
    end

    if (iter - lastImprovedIterRef[] >= iterStagnant) && any(phi .== 0.0)
        factor = 0.95 * log10(max(iter,1))/log10(maxIter)
        for i in 1:m
            phi[i] *= factor
        end
    end
end



function elaborateSolutionGreedyPhi!(phi, sol, A, C)
    m = length(phi)
    vConstraint = collect(1:m)

    utility = [sum(A[:,j] .!= 0) for j in 1:m]
    while !isempty(vConstraint)
        scores = phi[vConstraint] .* utility[vConstraint]
        idx = argmax(scores)
        chosen = vConstraint[idx]
        ktab = Int[]  
        ptab = [chosen] 
        isFeas, newMp = feasible(A, sol.mp, ktab, ptab, true)
        if isFeas
            sol.value[chosen] = 1
            sol.z += C[chosen]
            sol.feasible = true
            sol.mp .= newMp 
        end
        deleteat!(vConstraint, idx)
    end
end


function elaborateSolutionSelectionMethod!(phi, sol, A, C, iter, maxIter)
    m = length(phi)
    vConstraint = collect(1:m)

    utility = [sum(A[:,j] .!= 0) for j in 1:m]
    P = log10(max(iter,1)) / log10(maxIter)
    while !isempty(vConstraint)
        if rand() > P
            weights = phi[vConstraint] .* utility[vConstraint]
            if sum(weights) == 0
                idx = rand(1:length(vConstraint))
            else
                r = rand() * sum(weights)
                acc = 0.0
                idx = 1
                for (k,w) in enumerate(weights)
                    acc += w
                    if r <= acc
                        idx = k
                        break
                    end
                end
            end
        else
            scores = phi[vConstraint] .* utility[vConstraint]
            idx = argmax(scores)
        end
        chosen = vConstraint[idx]
        ktab = Int[]; ptab = [chosen]
        isFeas, newMp = feasible(A, sol.mp, ktab, ptab, true)
        if isFeas
            sol.value[chosen] = 1
            sol.z += C[chosen]
            sol.feasible = true
            sol.mp .= newMp 
        end
        deleteat!(vConstraint, idx)
    end
end



function ACO(A, C, maxAnt = 15, maxIter = 100, iterOnExploit = 3,rhoE = 0.05, rhoD = 0.1, iterStagnant = 20)
    m = length(C)
    n = maxAnt

    zbest = []
    zconstruction = []
    zamelioration = []

    bestZKnown = 0
    bestZIter = 0
    bestSolKnown = zeros(m)
    bestSolIter = zeros(m)
    phi = fill(0.5, m)

    pop = generatePopulation(n, m, A)

    lastImprovedIterRef = 0
    for iter in 1:maxIter
        bestZIter = 0
        bestSolIter = zeros(m)

        for antIdx in 1:n
            sol = Ant(zeros(m), 0.0, true, zeros(eltype(A), size(A,1)))
            if antIdx <= iterOnExploit
                elaborateSolutionGreedyPhi!(phi, sol, A, C)
            else
                elaborateSolutionSelectionMethod!(phi, sol, A, C, iter, maxIter)
            end
            push!(zconstruction, sol.z)

            sol.value, sol.z = SimpleDescent.runKPExchange(C, A, sol.value, sol.z,1,1,10)
            push!(zamelioration, sol.z)

            if sol.z > bestZIter
                bestZIter = sol.z
                bestSolIter = sol.value
            end
            if sol.z > bestZKnown
                bestSolKnown = sol.value
                bestZKnown = sol.z
                lastImprovedIterRef = iter
            end
            push!(zbest, bestZKnown)
        end

        managePheromones!(phi, bestSolKnown, bestSolIter, rhoE, rhoD, iter, maxIter,iterStagnant, lastImprovedIterRef)
    end

    return bestZKnown, zconstruction, zamelioration, zbest
end

