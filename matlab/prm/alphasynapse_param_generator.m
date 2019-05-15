%% AMPAR SYNAPSE - Alpha synapse
clc; clear; 
tau_S = 3; % ms
[alpha_S, beta_S, gamma_S] = exp1t_prm(tau_S); 

E_S = 0;
gmax_S = 25; 
delay_S = 2;

lst_prm = who; 
SYN_PRM = struct(); 
SYN_PRM.AMPAR = struct(); 
for i = 1:length(lst_prm) 
    prm_i = lst_prm{i};  
    SYN_PRM.AMPAR.(prm_i) = eval(prm_i);
end

%% GABAAR SYNAPSE - Alpha synapse
clearvars -except SYN_PRM lst_prm
tau_S = 10;  % ms
[alpha_S, beta_S, gamma_S] = exp1t_prm(tau_S); 

E_S = -80;
gmax_S = 25; 
delay_S = 5; 

SYN_PRM.GABAAR = struct(); 
for i = 1:length(lst_prm) 
    prm_i = lst_prm{i};  
    SYN_PRM.GABAAR.(prm_i) = eval(prm_i);
end


%% Save NRN_PRM
prm_folder = '.';
save(fullfile(prm_folder,'alphasyn_prm.mat'), 'SYN_PRM'); 



