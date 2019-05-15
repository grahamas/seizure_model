%% PYRAMIDAL NEURON
clc; clear; 
C = 1; 
SA = 9; 

E_L = -80; 
g_L = 8;  

E_Na = 60;
g_Na_max = 20; 
Vm_half = -20; 
km = 15; 

E_K = -90; 
g_K_max = 10; 
Vn_half = -25; 
kn = 5; 
taun = 1; 

lst_prm = who; 
NRN_PRM = struct(); 
NRN_PRM.PYR = struct(); 
for i = 1:length(lst_prm) 
    prm_i = lst_prm{i};  
    NRN_PRM.PYR.(prm_i) = eval(prm_i);
end

%% PARVALBUMIN NEURON
clearvars -except NRN_PRM lst_prm
C = 1; 
SA = 1; 

E_L = -78; 
g_L = 8;  

E_Na = 60;
g_Na_max = 20; 
Vm_half = -20; 
km = 15; 

E_K = -90; 
g_K_max = 10; 
Vn_half = -45; 
kn = 5; 
taun = 1; 

NRN_PRM.PV = struct(); 
for i = 1:length(lst_prm) 
    prm_i = lst_prm{i};  
    NRN_PRM.PV.(prm_i) = eval(prm_i);
end

%% Save NRN_PRM
prm_folder = 'prm';
save(fullfile(prm_folder,'nrn_prm.mat'), 'NRN_PRM'); 



