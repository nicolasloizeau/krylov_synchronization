using MathLink
using PauliStrings
using LinearAlgebra
using ProgressBars


"""
Lanczos algorithm for symbolic operators
"""
function lanczos(H::AbstractOperator, O::AbstractOperator, steps::Int; assumptions=nothing, returnOn=false, observer=false, show_progress=true)
    @assert typeof(H) == typeof(O)
    @assert observer === false || returnOn === false
    O0 = deepcopy(O)
    O0 /= norm(O0, normalize=true)
    O0 = simplify_operator(O0, assumptions=assumptions)
    LHO = simplify_operator(commutator(H, O0), assumptions=assumptions)
    b = simplify(norm(LHO, normalize=true), assumptions=assumptions)
    O1 = simplify_operator(commutator(H, O0) / b, assumptions=assumptions)
    bs = [b]
    returnOn && (Ons = [O0, O1])
    (observer !== false) && (obs = [observer(O0), observer(O1)])
    progress = collect
    show_progress && (progress = ProgressBar)
    for n in progress(0:steps-2)
        LHO = simplify_operator(commutator(H, O1), assumptions=assumptions)
        O2 = simplify_operator(LHO - b * O0, assumptions=assumptions)
        b = simplify(norm(O2, normalize=true), assumptions=assumptions)
        O2 /= b
        returnOn && push!(Ons, O2)
        (observer !== false) && push!(obs, observer(O2))
        O0 = deepcopy(O1)
        O1 = deepcopy(O2)
        push!(bs, b)
    end
    (observer !== false) && return (bs, obs)
    returnOn && (return bs, Ons)
    return bs
end
