function set_rect_coordinates(obj, rect_size)

% First obtain a grid
N = obj.num_neurons;
lenX = rect_size(1);
lenY = rect_size(2);

xvec = 1:lenX;
yvec = 1:lenY;

combo_coord = return_combomat(xvec, yvec);

% Shuffle the order
shuff_coord = combo_coord(randperm(N), :);

x = shuff_coord(:,1);
y = shuff_coord(:,2);

% Euclidean distance
dist_mat = euclidean_distance_matrix(x, y);

% Get center coordinate
xcent = ceil(lenX/2);
ycent = ceil(lenY/2);
cent_ind = find(x == xcent & y == ycent);

% Save to struct and fields
obj.coord = struct( 'x', x, 'y', y, ...
    'size', rect_size);
obj.dist = dist_mat;
obj.centered_neuron = struct( 'x', xcent, 'y', ycent, ...
    'ind', cent_ind);
end