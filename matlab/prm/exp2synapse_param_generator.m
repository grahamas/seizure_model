%% AMPAR SYNAPSE - Double exponential shape
clc; clear; 
taur_S = 3;
taud_S = 10; 
[alpha_S, beta_S, gamma_S] = exp2_prm(taur_S, taud_S); 

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

%% GABAAR SYNAPSE - Double exponential shape

clearvars -except SYN_PRM lst_prm
taur_S = 10;
taud_S = 60; 
[alpha_S, beta_S, gamma_S] = exp2_prm(taur_S, taud_S); 

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
save(fullfile(prm_folder,'doubleexpsyn_prm.mat'), 'SYN_PRM'); 