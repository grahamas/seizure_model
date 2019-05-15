%% Constants for LP and HP filter parameters for Vm 
% High pass Vm : to detect spike 
% Low pass Vm  : for driving force of AMPAR

clc; clear; 

APVf_thr = 20; 
d_APt = 1.5; 

F_Vf    = 0.2; % 0.2/ms = 200Hz 
tau_Vf  = 1/(2*pi*F_Vf);

F_Vs    = 0.01; % 0.01/ms = 10Hz 
tau_Vs  = 1/(2*pi*F_Vs); 

lst_prm = who; 

%% Save VMFILT_PRM
prm_folder = '.';
save(fullfile(prm_folder,'vmfilt_prm.mat'), lst_prm{:}); 
