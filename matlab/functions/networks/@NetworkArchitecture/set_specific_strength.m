function mu_s = set_specific_strength(obj, prm_strct)
% Necessary fields
try
    type_s = prm_strct.type;
catch
    error(['The weight struct needs to have at least this field:' ...
        ' `type`']);
end

% Default values of optional fields
k_s = return_field_value(prm_strct, 'k', inf);
m_s = return_field_value(prm_strct, 'm', 1);
bound_s = return_field_value(prm_strct, 'bound_weight', [0, 1]);
range_d = return_field_value(prm_strct, 'dist_range', [0, inf]);
def_s = return_field_value(prm_strct, 'def', 0);

% Get mu_s
mu_s = obj.return_mu_s(k_s, m_s, type_s, bound_s, range_d, def_s);
end

