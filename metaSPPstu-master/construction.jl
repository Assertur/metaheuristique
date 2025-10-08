function maxUtility(C, A, vConstraint, vVariable, alpha)
    # Function to find the index of the column with the maximum utility
    # Inputs: C : vector of costs   
    #         A : matrix of constraints
    #         V : vector of columns that can't be chosen anymore
    #         alpha : parameter to adjust the greediness of the heuristic
    # Output: iMax : index of the column with the maximum utility
    iValue = zeros(Float64,size(C,1))
    for i in 1:size(A,1)
        if !vConstraint[i]
            for j in 1:size(C,1)
                if !vVariable[j] && A[i,j] == 1
                    iValue[j] += 1
                end
            end
        end  
    end
    iMax = 1
    max = 0
    for i in 1:size(iValue,1)
        n = iValue[i]
        if n>0
            u = C[i]/n
            iValue[i] = u
            if u > max 
                max = u
                iMax = i
            end
        end
    end
    seuil = max*alpha
    possibilities = []
    for i in 1:size(iValue,1)
        if iValue[i]*alpha >= seuil
            possibilities = push!(possibilities,i)
        end
    end
    iMax = possibilities[rand(1:length(possibilities))]
    return iMax
end
        

function construction(C, A, alpha)
    # Function to construct a solution to the SPP using a greedy heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    choices = zeros(Int,1,size(C,1))
    vConstraint = falses(size(A,1))
    vVariable = falses(size(C,1))
    while false in vVariable
        mU = maxUtility(C, A, vConstraint, vVariable, alpha)
        vConstraint[mU] = true
        for i in 1:size(A,1)
            if A[i,mU] == 1
                vConstraint[i] = true
                for j in 1:size(C,1)
                    if A[i,j] == 1
                        vVariable[j] = true
                    end
                end
            end
        end
        choices[mU] = 1
    end
    z = 0
    for i in 1:length(choices)
        if choices[i] == 1
            z += C[i]
        end
    end
    return choices, z
end