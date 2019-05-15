%% Simulation variation parameters 
clc; clear; close all; 
prm_folder = 'prm'; 
data_folder = 'data/ffwd'; 
func_folder = 'functions'; 
addpath(prm_folder); 
addpath(func_folder); 


vec_GEmax = [0,4,8]; 
vec_GImax = [0,2,4]; 
vec_Inpmax = 700; 
vec_Inpdecay = [1/2,3/4,1]; 

combos = return_combomat(vec_GEmax,vec_GImax,vec_Inpmax,vec_Inpdecay);

for file_counter = 1:length(combos)
    GE_max = combos(file_counter,1); 
    GI_max = combos(file_counter,2);
    Iinp_max = combos(file_counter,3);
    Inp_decay = combos(file_counter,4); 
    run run_sim.m
end

save(fullfile(data_folder,'combo_var.mat'),'combos'); 