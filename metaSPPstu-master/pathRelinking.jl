function pathRelinking(A, C, s1, z1, s2, z2)
    mp = A * reshape(s1, :, 1)
    mp = vec(mp)
    bestz = z1
    bests = copy(s1)
    for i in eachindex(s1)
        if s1[i] != s2[i]
            new_s = copy(s1)
            new_s[i] = s2[i]
            new_z = z1
            if s2[i] == 1
                new_z += C[i]
            else
                new_z -= C[i]
            end
            isFeasible, mp = feasible(A, mp, s1[i]==1 ? [i] : Int[], s2[i]==1 ? [i] : Int[], true)   
            if isFeasible
                s_desc, z_desc = SimpleDescent.updateZ(C, A, new_s, new_z)
                if z_desc > bestz
                    bestz = z_desc
                    bests = copy(s_desc)
                end
            end
            z1 = new_z
            s1[i] = s2[i]
        end
    end 
    if bestz > z2
        return bests, bestz
    else
        return s2, z2
    end   
end