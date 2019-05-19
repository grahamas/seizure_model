@EI_kw_example function tuan(; common_dt::Float64=1/10, common_stop_time::Float64=20e2)
    simulation = Simulation(;
      model = HHNetwork(;
        space = Grid(extent=(300.0,300.0), n_points=(20,20)), #FIXME extent is a guess
        stimulus = RampingBumpStimulus(
          strength=700.0,
          peak_time=(3/5)*common_stop_time,
          width=ceil.(Int, sqrt(0.05) .* n_points)
        ),
        synapses = AMPAandGABASynapses(;
          E = [0.0 -80.0;
               0.0 -80.0],
          τ = [3.0 10.0;
               3.0 10.0],
          delay = [2.0 5.0;
                   2.0 5.0],
          connectivity = pops(DecayingExponentialConnectivity;
              amplitude = [10.0 -3.0;
                           10.0 -0.5],
              spread = [30.0 40.0;
                        30.0 40.0]
                      ) # Note that this should, perhaps be truncated
        ),
        neurons = pops(HHNeuron;
          C = [1.0, 1.0],
          E_K = [-90.0, -90.0],
          E_L = [-80.0, -78.0],
          E_Na = [60.0, 60.0],
          SA = [9.0, 1.0],
          V_m_half = [-20.0, -20.0],
          V_n_half = [-25.0, -45.0],
          g_K = [10.0, 10.0],
          g_L = [8.0, 8.0],
          g_Na = [20.0, 20.0],
          k_m = [15.0, 15.0],
          k_n = [5.0, 5.0],
          τ_n = [1.0, 1.0],
          τ_V_f = [1/(2*pi*0.2), 1/(2*pi*0.2)],
          τ_V_s = [1/(2*pi*0.01), 1/(2*pi*0.01)],
          dt_refractory = [common_dt, common_dt],
          threshold = [20.0, 20.0],
          N_per_point = [4, 1]
        )
      ),
      solver = Solver{Float64}(;
        stop_time = common_stop_time, #ms
        dt = common_dt #ms
      )
    )
end
