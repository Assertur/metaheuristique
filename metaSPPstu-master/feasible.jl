export feasible

function feasible(A, mp, kTab, pTab, acceptErr = false)
    # Function to check if a solution is feasible
    # Inputs: A : matrix of constraints, mp : matricial product of A and choices, kTab : variables to remove, pTab : variables to add     
    # Output: feasible : boolean indicating if the solution is feasible, the updated mp

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

    if feasible || acceptErr
        mp = temp
    end

    return feasible,mp
end