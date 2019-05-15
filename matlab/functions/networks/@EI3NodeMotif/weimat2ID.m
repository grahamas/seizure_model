function ID = weimat2ID(M)
persistent subgraph_keys subgraph_values
if isempty(subgraph_keys) 
    load('ei3nodemotif_library.mat', 'subgraph_keys', 'subgraph_values');
end

v = EI3NodeMotif.weimat2vec(M); 
k = EI3NodeMotif.hashed_vec(v); 
ID = subgraph_values(subgraph_keys == k); 
end