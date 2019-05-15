function [Emat, Imat] = template_ffwd_pair_synmat(N_nrn) 
N_pairs = N_nrn/2; 
if ~isinteger(N_pairs)
    error('Cannot create pairs because `N_nrn = %d` is odd', N_nrn);
end
    
Emat = zeros(N_nrn, N_nrn); 
Imat = zeros(N_nrn, N_nrn); 
for i = 1:N_pairs
    if i > 1
        Emat(i,i-1) = 1;
        Emat(i+N_pairs,i-1) = 1;
    end
    Imat(i,i+N_pairs) = 1;
end

end