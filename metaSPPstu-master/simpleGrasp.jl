function simpleGrasp(A,C,alpha)
    timer_start = time()
    #Greedy construction heuristic
    println("\nConstructing...")
    choices, z = construction(C, A, alpha) 
    println("z = ", z)
    #print("x = "); println(choices)
    println("Time taken for construction: ", time() - timer_start, " seconds")

    timer_start = time()
    #Simple descent heuristic
    println("\nImproving...")
    choices, z = SimpleDescent.updateZ(C, A, choices, z)
    println("z = ", z)
    println("Time taken for construction: ", time() - timer_start, " seconds")
    return z, choices
end