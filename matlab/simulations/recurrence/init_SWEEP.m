%% Define sweep parameters
run essential_startup.m

% Specify where you want to save your data to 
set_up.data_folder  = fullfile(set_up.head_dir, ...
                        'data/rec/');
                    
% Data file prefix for sweeping 
sweep_data_prefix_SIMGLOB = 'E2Esweep'; 

% Include structs that specify the values (numeric) in the format below to
% indicate what you want to vary, create as many structs as you want 
k_sE2E_SIMGLOB = struct('vec', [2,5,10,15,25], 'label', 'k_sE2E'); 
m_sE2E_SIMGLOB = struct('vec', [0.8,1,1.25,1.5,2], 'label', 'm_sE2E'); 

% Put all the structs in the `return_combination`, remember the order for
% later on 
[combo_vec_SIMGLOB, ~, combo_struct_SIMGLOB] = ...
    return_combination(k_sE2E_SIMGLOB, m_sE2E_SIMGLOB);

% You don't need to change this 
num_SIMGLOB = size(combo_vec_SIMGLOB,1); 
combo_struct_SIMGLOB.files = cell(num_SIMGLOB, 1); 

%% Initialize sweep 

% Going through the simulation
% Edit your "set_sim_SWEEP.m":
% 1. Change it with the fixed settings as you like 
% 2. For parameters you want to vary above, refer to inside the loop 

for i_SIMGLOB = 1 : num_SIMGLOB 
    file_pref = sprintf('%s_%03d', sweep_data_prefix_SIMGLOB, i_SIMGLOB); 
    combo_struct_SIMGLOB.files{i_SIMGLOB} = file_pref; 
    
    vec_i = combo_vec_SIMGLOB(i_SIMGLOB,:); 
    % 2.1. Here name the variables to something you that possibly don't overlap
    % with anything else in the code, don't end with "SIMGLOB"
    % 2.2. Remember the order as you have input with "return_combination"
    % 2.3. Then obtain the variables in the vector "vec_i"  
    k_sE2E = vec_i(1); 
    m_sE2E = vec_i(2); 
    
    % 2.4. Edit "set_sim_SWEEP.m" again, but place the variables you want
    % to sweep in the place of where they are in "set_sim_SWEEP.m"
    run set_sim_SWEEP.m
    close all 
    clearvars -except set_up *SIMGLOB
end

% Saving sweep master 
sweep_master = combo_struct_SIMGLOB; 
save(fullfile(set_up.data_folder, 'sweep_master.mat'), 'sweep_master'); 