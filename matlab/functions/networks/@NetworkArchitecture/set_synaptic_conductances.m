function [GE, GI] = set_synaptic_conductances(obj, G, scale_style)
scale_by = obj.return_synaptic_scale(scale_style);

try
    E2E = G.EtoE;
    E2I = G.EtoI;
    I2E = G.ItoE;
    I2I = G.ItoI;
catch
    error(['`G` has to have these fields: ' ...
        '`EtoE`, `EtoI`, `ItoE`, `ItoI`']);
end

PE = obj.pop_ind.PE;
PI = obj.pop_ind.PI;

SE = scale_by * obj.syn_strength.SE;
SI = scale_by * obj.syn_strength.SI;

GE = zeros(size(SE));
GI = zeros(size(SI));

% (TO, FROM)
GE(PE, PE) = E2E * SE(PE, PE);
GE(PI, PE) = E2I * SE(PI, PE);

GI(PE, PI) = I2E * SI(PE, PI);
GI(PI, PI) = I2I * SI(PI, PI);

obj.syn_conductance = struct('GE', GE, 'GI', GI);
end
