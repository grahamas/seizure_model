function set_lattice_coordinates(obj, lat_tmpl, ind_tmpl, dist_majr)

% Recalculating number of neurons needed for template and final lattice
N = obj.num_neurons; 

num_nrn_lat = size(lat_tmpl, 1);
num_on_side = ceil(sqrt(N/num_nrn_lat)); 
num_tmpl = num_on_side^2; 
new_num_neurons = num_nrn_lat * num_tmpl; 

% Major lattice to distribute the template 
axis_majr = (0:(num_on_side-1)) * dist_majr; 
lat_majr = return_combination(axis_majr, axis_majr); 

% Final lattice and marked indices
lat_finl = arrayfun(@(i) lat_tmpl + lat_majr(i,:), 1:num_tmpl, 'uni', 0);
lat_finl = vertcat(lat_finl{:}); 
ind_finl = repmat(ind_tmpl, [num_tmpl, 1]); 

% Reorganize indices to have first PE (+1) then PI (-1)
[~, ind_sorted] = sort(ind_finl, 'descend'); 
ind_finl = ind_finl(ind_sorted); 
lat_finl = lat_finl(ind_sorted, :); 
 
% Reset population indices 
PE = sort(find(ind_finl == +1), 'ascend'); 
PI = sort(find(ind_finl == -1), 'ascend'); 

obj.num_neurons = new_num_neurons;
obj.pop_ind = struct('PE', PE, 'PI', PI, 'Pmarked', ind_finl);

% Obtain the pseudo coordinates
x = lat_finl(:,1);
y = lat_finl(:,2);

% Euclidean distance
dist_mat = euclidean_distance_matrix(x, y);

% Get center coordinate
xcent = mean(x); 
ycent = mean(y); 
dist2cent = sqrt((x - xcent).^2 + (y - ycent).^2);  
[~, cent_ind] = min(dist2cent); 
xcent = x(cent_ind); 
ycent = y(cent_ind); 

% Save to struct and fields
obj.coord = struct( 'x', x, 'y', y);
obj.dist = dist_mat;
obj.centered_neuron = struct( 'x', xcent, 'y', ycent, ...
    'ind', cent_ind);

end
