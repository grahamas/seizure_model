function [alpha_S, beta_S, gamma_S] = exp1t_prm(tau_S)
BETA_S = 1/tau_S; 
alpha_S = BETA_S;
beta_S = -2*BETA_S; 
gamma_S = -BETA_S^2; 

end