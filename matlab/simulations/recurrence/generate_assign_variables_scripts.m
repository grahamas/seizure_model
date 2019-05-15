%% For neuron intrinsic variables

lst_nrn_prm = fieldnames(exc_nrn); 
pad_prm_nme = pad(lst_nrn_prm); 
cellfun(@(a,b) fprintf('%s\t=\tintr_var_strct.%s;\n', a, b), ...
    pad_prm_nme, lst_nrn_prm);

%% For synaptic constant variables
lst_syn_prm = fieldnames(exc_syn); 

pad_excsyn_name = pad(strcat(lst_syn_prm, '_e'));  
cellfun(@(a,b) fprintf('%s\t=\texc_syn.%s;\n', a, b), ...
    pad_excsyn_name, lst_syn_prm);

fprintf('\n'); 
pad_inhsyn_name = pad(strcat(lst_syn_prm, '_i'));
cellfun(@(a,b) fprintf('%s\t=\tinh_syn.%s;\n', a, b), ...
    pad_inhsyn_name, lst_syn_prm);
