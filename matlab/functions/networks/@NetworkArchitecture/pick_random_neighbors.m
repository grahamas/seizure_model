function neigh_ind = pick_random_neighbors(obj, num_neigh, start_ind)
N = obj.num_neurons;

if nargin < 2 || num_neigh < 1
    num_neigh = 1;
end
if nargin < 3
    start_ind = randi(N);
else
    if ischar(start_ind)
        switch upper(start_ind)
            case 'RANDOM'
                start_ind = randi(N);
            case 'CENTER'
                start_ind = obj.centered_neuron.ind;
            otherwise
                error(['`start_ind` can only be numeric, or ' ...
                    'either of these strings: "random", "center"']);
        end
    end
end

dist2neighs = obj.dist(start_ind,:);
[~, sorted_neighs] = sort(dist2neighs, 'ascend');
num2pickfrom = min([N - 1, num_neigh]);
neigh_ind = sorted_neighs(randperm(num2pickfrom, num_neigh) + 1);

end