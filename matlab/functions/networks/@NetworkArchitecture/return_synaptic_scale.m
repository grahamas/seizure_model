function res = return_synaptic_scale(obj, scale_style)
N = obj.num_neurons;
switch upper(scale_style)
    case 'UNITY'
        res = 1;
    case 'LINEAR'
        res = 1/N;
    case 'SQRT'
        res = 1/sqrt(N);
    otherwise
        error(['The synaptic conductance scale type can only' ...
            ' be either of these: "UNITY", "LINEAR" or "SQRT"']);
end
end
