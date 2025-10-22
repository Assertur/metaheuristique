function pathRelinking(A, C, s1, z1, s2, z2)
    mp = A * reshape(s1, :, 1)
    mp = vec(mp)
    bestz = z1
    bests = copy(s1)
    for i in eachindex(s1)
        if s1[i] != s2[i]
            new_s = copy(s1)
            new_s[i] = s2[i]
            if s2[i] == 1
                z1 += C[i]
            else
                z1 -= C[i]
            end 
            if z1 > bestz
                isFeasible, mp = feasible(A, mp, s1[i]==1 ? [i] : Int[], s2[i]==1 ? [i] : Int[])   
                if isFeasible
                    bestz = z1
                    bests = copy(new_s)
                end
            end
            s1 = copy(new_s)
        end
    end 
    if bestz > z2
        return bests, bestz
    else
        return s2, z2
    end   
end