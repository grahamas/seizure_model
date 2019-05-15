classdef EI3NodeMotif < handle 
    properties (Constant)
        num_nodes = 3;
        possible_weights = [-1, 0, 1];
        num_nonidentity = 6;
        ind_nonidentity = [2:4, 6:8]; 
    end
    methods (Static)
        create_library
        
        v = weimat2vec(M) 
        
        M = vec2weimat(v) 
        
        ID = weimat2ID(M)
        
        M = ID2mat(id)
        
        function x = hashed_vec(v)
            conv_factor = 3.^(5:-1:0); 
            x = sum((v + 1) .* conv_factor, 2);
        end
    end
end
