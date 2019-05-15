
@with_kw struct HHNeuron{T}
    C::T
    E_K::T
    E_L::T
    E_Na::T
    SA::T
    V_m_half::T
    V_n_half::T
    g_K::T
    g_L::T
    g_Na::T
    k_m::T
    k_n::T
    τ_n::T
    τ_V_f::T
    τ_V_s::T
end

function Θ(V, V_half, K)
    1 / (1 + exp((V_half - V) / K))
end

function make_mutator(neuron::HHNeuron)
    @unpack_HHNeuron neuron # FIXME I am dangerous
    function neuron_mutator!(d_neuron_state, neuron_state, t)
        # Gets neuron_state of single neuron, so neuron_state[1] is V, neuron_state[2] is n,
        # neuron_state[3] = V_f (high pass), neuron_state[4] = V_s (low pass)
        @views begin
            dV, dn, dV_f, dV_s = d_neuron_state.x.x[1:4]
            V, n, V_f, V_s = neuron_state.x.x[1:4]
            @. n_∞ = Θ(V, V_n_half, k_n)
            @. m_∞ = Θ(V, V_m_half, k_m)
            @. dV += g_L * (E_L - V)
            @. dV += g_Na * m_∞ * (E_Na - V)
            @. dV += g_K * n * (E_K - V)
            @. dn += (n_∞ - n) / τ_n
            @. dV_f += dV - (V_f / τ_V_f)
            @. dV_s += (V - V_s) / τ_V_s
        end
    end
end
