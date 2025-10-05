function feasibleExchange(A, choices)
    # Function to check if a solution is feasible
    # Inputs: A : matrix of constraints
    #         choices : vector of choices
    # Output: feasible : boolean indicating if the solution is feasible
    c = reshape(choices, :, 1)
    temp = A * c

    return all(temp .<= 1)
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
                        println(new_choices)
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