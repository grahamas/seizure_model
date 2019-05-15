function  M = ID2mat(id)
persistent subgraph_matrices subgraph_values
if isempty(subgraph_matrices) 
    load('ei3nodemotif_library.mat', 'subgraph_matrices', 'subgraph_values');
end
M = subgraph_matrices(subgraph_values == id); 

end