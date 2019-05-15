function [alpha_S, beta_S, gamma_S] = exp2_prm(tau_Rise, tau_Decay)
t_peak = tau_Rise*tau_Decay*log(tau_Decay/tau_Rise)/(tau_Decay - tau_Rise); 
normz_factor = 1/(exp(-t_peak/tau_Decay) - exp(-t_peak/tau_Rise));
alpha_S = normz_factor*(1/tau_Rise - 1/tau_Decay); 
beta_S  = -(1/tau_Rise + 1/tau_Decay); 
gamma_S = -1/(tau_Rise * tau_Decay); 
end