function maxUtility(C, A, V)
    iMax = 0
    max = 0
    for i in size(A[0],1)
        n = 0
        for j in size(A,1)
            if j ∉ V
                if A[j][i]
                    n ++
        if n>0
            u = C[i]/n
            if u > max 
                max = u
                iMax = i
    return iMax
        

function construction(C, A)
    choices = zeros(Int,1,size(C,1))
    v = []
    while size(v,1) < size(A,1)
        mU = maxUtility(C, A, v)
        for i in size(A,1)
            if A[i][mU] == 1
                v + [i]
        choices[mU] = 1
    z = 0
    for i in size(choices,1)
        z += C[choices[i]]
    return choices, z