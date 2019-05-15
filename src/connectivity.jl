
abstract type AbstractSynapse{T} end

@with_kw struct AMPASynapse{T} <: AbstractSynapse{T}
    E::T
    τ::T
    α::T
    β::T
    γ::T
    delay::T
    g_max::T
end
# FIXME recent PR allows abstract constructors
function AMPASynapse(; E::T=nothing, delay::T=nothing, g_max::T=nothing, τ::T=nothing) where T
    α = 1/τ
    AMPASynapse{T}(E, τ, α, -2α, -α^2, delay, g_max)
end

@with_kw struct GABASynapse{T} <: AbstractSynapse{T}
    E::T
    τ::T
    α::T
    β::T
    γ::T
    delay::T
    g_max::T
end
function GABASynapse(; E::T=nothing, delay::T=nothing, g_max::T=nothing, τ::T=nothing) where T
    α = 1/τ
    GABASynapse{T}(E, τ, α, -2α, -α^2, delay, g_max)
end


# FIXME collapse these functions into one with the cardinal difference (V_s vs V) dispatched
# State.last_spike_time is array containing last spike time
# State.x[1] is neuronE
# State[1][1] is V_E
# State[1][2] is n_E
# State[1][3] = V_f (high pass)
# State[1][4] = V_s (low pass)
# State[1][5] is g_AMPA
# State[1][6] is z_AMPA
# State[1][7] is g_GABA
# State[1][8] is z_GABA
# State[2] is neuronI
# ..
function detect_spikes(state, history, p, t, dt, presynapse_ix)
    Vf_before = history(p, t-dt).x[presynapse_ix].x.x[3]
    Vf_at = history(p, t).x[presynapse_ix].x.x[3]
    Vf_after = history(p, t+dt).x[presynapse_ix].x.x[3]

    last_spike_time = history(p,t).x[presynapse_ix].last_spike_time
    dt_refractory = history(p,t).x[presynapse_ix].dt_refractory
    threshold = history(p,t).x[presynapse_ix].threshold

    @. spikes_bitarr = ((Vf_at > threshold)
                         & (Vf_before <= Vf_at)
                         & (Vf_after <= Vf_at)
                         & (t - last_spike_time) > dt_refractory)
    return spikes_bitarr
end

function mutate_potential!(syn::AMPASynapse, d_neuron_state, neuron_state)
    Vs = neuron_state.x.x[4]
    @. d_neuron_state.x.x[1] += syn.g * (syn.E * Vs)
end
function mutate_potential!(syn::GABASynapse, d_neuron_state, neuron_state)
    V = neuron_state.x.x[1]
    @. d_neuron_state.x.x[1] += syn.g * (syn.E * V)
end
function mutate_conductance!(syn::AMPASynapse, d_neuron_state, neuron_state, presynaptic_spikes)
    d_g, d_z = d_neuron_state.x.x[[5,6]]
    g, z = neuron_state.x.x[[5,6]]
    @. x= g_max * neuron_I_spikes
    @. d_z += syn.α * x + syn.β * z + syn.γ * g
    @. d_g += z
end
function mutate_conductance!(syn::GABASynapse, d_neuron_state, neuron_state, presynaptic_spikes)
    d_g, d_z = d_neuron_state.x.x[[7,8]]
    g, z = neuron_state.x.x[[7,8]]
    @. x = g_max * presynaptic_spikes
    @. d_z += syn.α * x + syn.β * z + syn.γ * g
    @. d_g += z
end

function make_mutator(synapse::T_syn, presynapse_ix::Int, dt::Float64) where {T_syn <: AbstractSynapse}
    function synapse_mutator!(d_state, state, history, p, t)
        @views begin
            presynaptic_spikes = detect_spikes(state, history, t-delay, dt, presynapse_ix)
            for i in 1:2 # number of neuron types
                d_neuron_i = d_state.x[i]
                neuron_i = state.x[i]
                mutate_potential!(synapse, d_neuron_i, neuron_i)
                mutate_conductance!(synapse, d_neuron_i, neuron_i, presynaptic_spikes)
            end
        end
    end
end
