function set_strength_matrices(obj, weight_prm)
% Obtain MU_S for different specific connections
try
    sprm_E2E = weight_prm.EtoE;
    sprm_E2I = weight_prm.EtoI;
    sprm_I2E = weight_prm.ItoE;
    sprm_I2I = weight_prm.ItoI;
catch
    error(['The `weight_prm` struct needs to have these fields: ' ...
        '`EtoE`, `EtoI`, `ItoE`, `ItoI`']);
end

mu_sE2E = obj.set_specific_strength(sprm_E2E);
mu_sE2I = obj.set_specific_strength(sprm_E2I);
mu_sI2E = obj.set_specific_strength(sprm_I2E);
mu_sI2I = obj.set_specific_strength(sprm_I2I);

% Assign to general matrices SE and SI
PE = obj.pop_ind.PE;
PI = obj.pop_ind.PI;

SE = zeros(size(mu_sE2E));
SI = zeros(size(mu_sE2E));

% (TO, FROM)
SE(PE, PE) = mu_sE2E(PE, PE);
SE(PI, PE) = mu_sE2I(PI, PE);

SI(PE, PI) = mu_sI2E(PE, PI);
SI(PI, PI) = mu_sI2I(PI, PI);

obj.syn_strength = struct('SE', SE, 'SI', SI );
end