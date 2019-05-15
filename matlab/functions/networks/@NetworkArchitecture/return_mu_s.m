function mu_s = return_mu_s(obj, k_s, m_s, type_s, ...
    bound_s, range_d, def_s)
dist_mat = obj.dist;

% MU_S depends on the type of spatial kernel/dependence
if isinf(k_s) && ~strcmpi(type_s, 'RECT')
    error('Cannot have `type` = "RECT" if `k` = inf');
end

switch upper(type_s)
    case 'EXP'
        mu_s = m_s * exp(-dist_mat / k_s);
    case 'GAUSS'
        mu_s = m_s * exp(-dist_mat.^2 / k_s);
    case 'RECT'
        mu_s = m_s * ones(size(dist_mat));
    otherwise
        error(['Type of spatial-related synaptic normalized' ...
            ' strengths could only be "EXP" for exponential decay,' ...
            ' "GAUSS" for a Gaussian-shaped decay, or' ...
            ' "RECT" for a constant value.']);
end

% Bounded distance
if range_d(1) >= range_d(2)
    error(['Distance range needs to be a 2-element ' ...
        'vector with increasing value']);
end

mu_s(dist_mat < range_d(1) | dist_mat > range_d(2)) = def_s;

% Hard-bounded weight (strength)
if bound_s(1) >= bound_s(2)
    error(['Weight bound needs to be a 2-element ' ...
        'vector with increasing value']);
end

zero_self = 1 - eye(obj.num_neurons);
mu_s(isinf(mu_s) | isnan(mu_s)) = 0;
mu_s = bound_minmax(mu_s, bound_s(1), bound_s(2)) .* zero_self;
end
