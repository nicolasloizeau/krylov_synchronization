using MathLink
using PauliStrings
using LinearAlgebra
using ProgressBars
include("lanczos.jl")


"""
Saw model Hamiltonian with disorder strength W, eq (4) of the paper
"""
function saw(N, h1, h2, J)
    H = OperatorMathLink(N)
    for i in 1:2:N
        H += h1, "X", i
    end
    for i in 2:2:N
        H += h2, "X", i
    end
    for i in 1:N
        H += J, "X", i, "X", mod1(i + 1, N)
        H += J, "Y", i, "Y", mod1(i + 1, N)
        H += J, "Z", i, "Z", mod1(i + 1, N)
    end
    return H
end
saw(N, W) = saw(N, 1 - W, 1 + W, 1)


"""
Z + iY on every site
"""
function Sp(N)
    O = OperatorMathLink(N)
    for i in 1:N
        O += 1, "Z", i
        O += 1im, "Y", i
    end
    return O
end



W = W"W" # symbolic variable for disorder strength
N = 14 # system size
H = saw(N, W) # Saw model Hamiltonian
O = Sp(N) #S+ operator

println(typeof(O))

# assumptions for symbolic simplification
assumptions = W`Assumptions -> W > 0`

# compute the first 6 Lanczos coefficients
bn = lanczos(H, O, 6; assumptions=assumptions)

for b in bn
    println()
    println(b)
end
