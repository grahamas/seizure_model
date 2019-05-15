function set_population_indices(obj, num_neurons, prob_e)
NE = ceil(prob_e*num_neurons);
PE = 1:NE;
PI = (NE+1):num_neurons;

Pmarked = zeros(num_neurons);
Pmarked(PE) = +1;
Pmarked(PI) = -1;

obj.num_neurons = num_neurons;
obj.pop_ind = struct('PE', PE, 'PI', PI, 'Pmarked', Pmarked);
end