%% Define sweep parameters
run essential_startup.m

set_up.data_folder  = fullfile(set_up.head_dir, ...
                        'data/rec/prmsweep_E2E');
                    
k_sE2E_SIMGLOB = struct('vec', [2,5,10,15,25], 'label', 'k_sE2E'); 
m_sE2E_SIMGLOB = struct('vec', [0.8,1,1.25,1.5,2], 'label', 'm_sE2E'); 

[combo_vec_SIMGLOB, ~, combo_struct_SIMGLOB] = ...
    return_combination(k_sE2E_SIMGLOB, m_sE2E_SIMGLOB);

num_SIMGLOB = size(combo_vec_SIMGLOB,1); 
combo_struct_SIMGLOB.files = cell(num_SIMGLOB, 1); 

%% Initialize sweep 

for i_SIMGLOB = 1 : num_SIMGLOB 
    file_pref = sprintf('E2Esweep_%03d', i_SIMGLOB); 
    combo_struct_SIMGLOB.files{i_SIMGLOB} = file_pref; 
    
    vec_i = combo_vec_SIMGLOB(i_SIMGLOB,:); 
    k_sE2E = vec_i(1); 
    m_sE2E = vec_i(2); 
    
    run set_sim_E2Esweep.m
    close all 
    clearvars -except set_up *SIMGLOB
end

sweep_master = combo_struct_SIMGLOB; 
save(fullfile(set_up.data_folder, 'sweep_master.mat'), 'sweep_master'); 