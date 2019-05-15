function create_library
persistent num_nodes possible_weights num_nonidentity
if isempty(num_nodes)
    num_nodes = EI3NodeMotif.num_nodes;
    possible_weights = EI3NodeMotif.possible_weights;
    num_nonidentity = EI3NodeMotif.num_nonidentity;
end

all_wei_combos = return_combination(possible_weights, 'num', num_nonidentity);
all_wei_combos = sortrows(all_wei_combos); 

n_combos = size(all_wei_combos,1);
raw_ids = 1:n_combos;

all_node_perms = perms(1:num_nodes); 
n_perms = size(all_node_perms, 1); 

subgraph_matrices = cell(n_combos, 1); 

for i = 1:n_combos
    mat_i = EI3NodeMotif.vec2weimat(all_wei_combos(i,:));
    subgraph_matrices{i} = mat_i; 
    
    if i == n_combos
        break;
    end
    
    for j = (i + 1):n_combos
        mat_j = EI3NodeMotif.vec2weimat(all_wei_combos(j,:));
        
        for k = 1:n_perms
            perm_k = all_node_perms(k,:); 
            perm_j = mat_j(perm_k, perm_k); 
            
            if isequal(perm_j, mat_i)
                raw_ids(j) = raw_ids(i);
                break; 
            end
        end

    end
end

[~, ~, subgraph_values] = unique(raw_ids); 

subgraph_keys = EI3NodeMotif.hashed_vec(all_wei_combos); 

save('ei3nodemotif_library.mat', 'subgraph_keys', 'subgraph_values', 'subgraph_matrices'); 
end