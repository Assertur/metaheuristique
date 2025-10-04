function maxUtility(C, A, V)
    # Function to find the index of the column with the maximum utility
    # Inputs: C : vector of costs   
    #         A : matrix of constraints
    #         V : vector of columns that can't be chosen anymore
    # Output: iMax : index of the column with the maximum utility
    iMax = 1
    max = 0
    for i in 1:size(C,1)
        n = 0
        for j in 1:size(A,1)
            if i ∉ V && A[j,i] == 1
                n += 1
            end
        end
        if n>0
            u = C[i]/n
            if u > max 
                max = u
                iMax = i
            end
        end
    end
    println("iMax = ", iMax)
    return iMax
end
        

function construction(C, A)
    # Function to construct a solution to the SPP using a greedy heuristic
    # Inputs: C : vector of costs
    #         A : matrix of constraints
    # Outputs: choices : vector of choices
    #          z : cost of the solution
    choices = zeros(Int,1,size(C,1))
    v = []
    while size(v,1) < size(C,1)
        println("v = ", v)  
        mU = maxUtility(C, A, v)
        push!(v, mU)
        for i in 1:size(A,1)
            if A[i,mU] == 1
                for j in eachindex(A[i,:])
                    if j ∉ v && A[i,j] == 1
                        push!(v, j)
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