module SimpleDescent
# Using the following packages
using Combinatorics

export updateZ


function feasibleExchange(A, choices)
    # Function to check if a solution is feasible
    # Inputs: A : matrix of constraints
    #         choices : vector of choices
    # Output: feasible : boolean indicating if the solution is feasible
    c = reshape(choices, :, 1)
    temp = A * c

    return all(temp .<= 1)
end

function sufisanteX(choices, k, remove)
    # Function to check if there are at least k variables chosen in the solution
    # Inputs: choices : vector of choices
    #         k : number of variables to remove or to add
    #         remove : boolean indicating if we are removing or adding variables
    # Output: boolean indicating if there are at least k variables chosen
    n = 0
    if remove
        for i in eachindex(choices)
            if choices[i] == 1
                n += 1
            end
        end
        else
            for i in eachindex(choices)
                if choices[i] == 0
                    n += 1
                end
            end
        end
    return n >= k
end

function exchange11(C, A, choices, z)
    #Horrible running time (O(n^3))

    # Function to improve a solution to the SPP using a simple descent heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    #         choices : vector of choices
    #         z : cost of the solution
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    improved = true
    while improved
        improved = false
        i = 1
        while i < length(choices) && !improved
            j = 1
            while j < length(choices) && !improved
                new_z = z - C[i] + C[j]
                if choices[i] == 1 && choices[j] == 0 && new_z > z
                    new_choices = copy(choices)
                    new_choices[i] = 0
                    new_choices[j] = 1
                    if feasibleExchange(A, new_choices)
                        choices , z = new_choices, new_z
                        improved = true
                    end
                end
                j += 1
            end
            i += 1
        end
    end
    return choices, z
end

function kpExchange(C, A, choices, z, k, p)
    # Function to improve a solution to the SPP using a k-p exchange heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    #         choices : vector of choices
    #         z : cost of the solution
    #         k : number of variables to remove
    #         p : number of variables to add
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    if !sufisanteX(choices, k, true) || !sufisanteX(choices, p, false)
        error("Not enough variables to remove or to add")
    end
    kChoices = Int[]
    pChoices = Int[]
    for iC in eachindex(choices)
        if choices[iC] == 1
            push!(kChoices, iC)
        else
            push!(pChoices, iC)
        end
    end
    for kTab in combinations(kChoices, k)
        for pTab in combinations(pChoices, p)
            new_z = z
            for iT in eachindex(kTab)
                new_z -= C[kTab[iT]]
            end
            for jT in eachindex(pTab)
                new_z += C[pTab[jT]]
            end
            if new_z > z
                new_choices = copy(choices)
                for i in eachindex(kTab)
                    new_choices[kTab[i]] = 0
                end
                for j in eachindex(pTab)
                    new_choices[pTab[j]] = 1
                end
                if feasibleExchange(A, new_choices)
                    choices , z = new_choices, new_z
                    return choices, z
                end
            end
        end
    end
    return choices, z
end

function runKPExchange(C, A, choices, z, k, p, max_iteration)
    # Function to improve a solution to the SPP using a k-p exchange heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    #         choices : vector of choices
    #         z : cost of the solution
    #         k : number of variables to remove
    #         p : number of variables to add
    #         max_iteration : maximum number of iterations
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    i = 1
    while i <= max_iteration
        new_choices, new_z = kpExchange(C, A, choices, z, k, p)
        if new_z > z
            choices = new_choices
            z = new_z
            println("z = ", z)
        else
            println("fin du kpExchange pour i = ", i, " k = ", k, " p = ", p)
            if choices == new_choices
                i = max_iteration + 1
            end
        end
        i += 1
    end
    return choices, z
end


function updateZ(C, A, choices, z)
    # Function to improve a solution to the SPP using a simple descent heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    #         choices : vector of choices
    #         z : cost of the solution
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    choices, z = runKPExchange(C, A, choices, z, 2, 2, 20)
    choices, z = runKPExchange(C, A, choices, z, 1, 1, 15)
    choices, z = runKPExchange(C, A, choices, z, 0, 1, 10)
    return choices, z
end
end