module SimpleDescent
# Using the following packages
using Combinatorics

export updateZ


function feasibleExchange(A, mp, kTab, pTab)
    # Function to check if a solution is feasible
    # Inputs: A : matrix of constraints
    #         choices : vector of choices
    # Output: feasible : boolean indicating if the solution is feasible

    temp = copy(mp)

    for k in eachindex(kTab)
        for c in 1:size(A,1)
            temp[c] -= A[c, kTab[k]]
        end
    end 
    for p in eachindex(pTab)
        for c in 1:size(A,1)
            temp[c] += A[c, pTab[p]]
        end
    end

    feasible = all(temp .<= 1)

    if feasible
        mp = temp
    end

    return feasible,mp
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
    mp = A * reshape(choices, :, 1) # Matricial product to check if the solution is feasible
    mp = vec(mp) 
    if sufisanteX(choices, k, true) && sufisanteX(choices, p, false)
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
                    feasible, new_mp = feasibleExchange(A, mp, kTab, pTab)
                    if feasible
                        new_choices = copy(choices)
                        mp = new_mp
                        for i in eachindex(kTab)
                            new_choices[kTab[i]] = 0
                        end
                        for j in eachindex(pTab)
                            new_choices[pTab[j]] = 1
                        end
                        return new_choices, new_z
                    end
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
        else
           # println("fin du kpExchange pour i = ", i, " k = ", k, " p = ", p, " z = ", z)
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
    choices, z = runKPExchange(C, A, choices, z, 1, 2, 10)
    choices, z = runKPExchange(C, A, choices, z, 1, 1, 10)
    choices, z = runKPExchange(C, A, choices, z, 0, 1, 10)
    return choices, z
end
end