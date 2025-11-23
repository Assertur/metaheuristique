function generatePopulation(n, C)
    #Create a population of n ant
    pop = []
    for i in 1:n 
        ant = [zeros(Int16, size(C,1) ),0,true]
        push!(pop,ant)
    end
    return pop
end

function feasibleACO(A, C, ant, randC)
    isAdd = ant[1][randC] == 1
    if !ant[3] && isAdd 
        return false
    elseif ant[3] && !isAdd
        return true
    end
    active = findall(x -> x == 1, ant[1])
    for i in 1:size(A,1)
        cpt = 0
        for j in active
            if A[i,j] == 1
                cpt += 1
                if cpt > 1
                    return false
                end
            end
        end
    end
    return true
end


function exploration(pheromone, C, pop, A, maxZ)
    for i in 1:size(pop,1)
        ant = pop[i]
        oldZ = ant[2]
        if oldZ == 0
            oldZ = 1
        end
        newV = 0
        isChanged = false
        randC = 0
        nbTries = 0
        while !isChanged && nbTries < 100
            randC = rand(1:size(C,1))
            randP = rand()
            newV = 0
            if randP <= pheromone[randC]
                newV = 1
            end
            if ant[1][randC] != newV
                isChanged = true
            end
            nbTries += 1
        end
        if isChanged
            ant[1][randC] = newV
            isFeasible = feasibleACO(A, C, ant, randC)
            z = 0
            if isFeasible
                for i in 1:length(ant[1])
                    if ant[1][i] == 1
                        z += C[i]
                    end
                end
            end
            ant[2] = z
            ant[3] = isFeasible
            p = (ant[2] - oldZ)/oldZ
            if newV == 1
                newPheromone = pheromone[randC] + p 
            else
                newPheromone = pheromone[randC] - p 
            end
            if newPheromone < 0 
                newPheromone = 0
            elseif newPheromone > 1
                newPheromone = 1
            end
            pheromone[randC] = newPheromone
            if ant[2] > maxZ
                maxZ = ant[2]
            end
        end
    end
    return maxZ
end

function dissipation(pheromone)
    for i in 1:size(pheromone,1)
        if pheromone[i] > 0.5
            pheromone[i] = pheromone[i] - 0.01
        elseif pheromone[i] < 0.5
            pheromone[i] = pheromone[i] + 0.01
        end
    end
end

function ACO(n, A, C, nbMouv, nbGen)
    pheromone = [0.5 for i in 1:size(C,1)]
    maxZ = 0
    for i in 1:nbGen
        pop = generatePopulation(n, C)
        for j in 1:nbMouv
            maxZ = exploration(pheromone, C, pop, A, maxZ)
            dissipation(pheromone)
        end
        println("maxZ : ", maxZ)
    end
    return maxZ
end