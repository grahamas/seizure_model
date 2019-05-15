function set_sphere_coordinates(obj, normz_style)

% Obtain x, y, z coordinate of a Fibonaci sphere
% with a certain normalization for the smallest dist = 1
N = obj.num_neurons;
[x, y, z] = fib_sphere(N, normz_style);

% Shuffle the order
shuff_ind = randperm(N);

x = x(shuff_ind);
y = y(shuff_ind);
z = z(shuff_ind);

% Get distance matrix based on the `normz_style`
dist_mat =  spherical_distance_matrix(x, y, z, normz_style);

% Hemisphere indinces, +1 -> upper, -1 -> lower
hemi_ind = zeros(size(z));
hemi_ind(z >= 0) = +1; % upp
hemi_ind(z <  0) = -1; % low

% Assume center is the highest point
[~, ind_zmax] = max(z);

xcent = x(ind_zmax);
ycent = y(ind_zmax);

% Projection onto the plane z = min(z)
R_est = max(sqrt(x.^2 + y.^2 + z.^2), [], 'all');
proj_x = R_est * x ./ (R_est + abs(z));
proj_y = R_est * y ./ (R_est + abs(z));

% Keep them apart for plotting purposes
horz_shift = 1.2*(max(proj_x(:)) - min(proj_x(:)));
low_hemi = hemi_ind == -1;
proj_x(low_hemi) = proj_x(low_hemi) + horz_shift;

% Center
proj_xcent = proj_x(ind_zmax);
proj_ycent = proj_y(ind_zmax);

% Save to struct and fields
obj.coord = struct( 'x', x, 'y', y, 'z', z, ...
    'hemi_ind', hemi_ind, ...
    'proj_x', proj_x, 'proj_y', proj_y);
obj.dist = dist_mat;
obj.centered_neuron = struct( 'x', xcent, 'y', ycent, ...
    'ind', ind_zmax, ...
    'proj_xcent', proj_xcent, ...
    'proj_ycent', proj_ycent);

end