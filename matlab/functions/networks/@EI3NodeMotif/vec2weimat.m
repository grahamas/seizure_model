function M = vec2weimat(v) 
persistent num_nodes ind_nonidentity
if isempty(num_nodes)
    num_nodes = EI3NodeMotif.num_nodes;
    ind_nonidentity = EI3NodeMotif.ind_nonidentity; 
end

M = zeros(num_nodes, num_nodes);
M(ind_nonidentity) = v; 

end