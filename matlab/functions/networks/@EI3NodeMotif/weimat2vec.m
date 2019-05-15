function v = weimat2vec(M) 
persistent ind_nonidentity
if isempty(ind_nonidentity)
    ind_nonidentity = EI3NodeMotif.ind_nonidentity; 
end

v = to_row_vec(M(ind_nonidentity)); 

end