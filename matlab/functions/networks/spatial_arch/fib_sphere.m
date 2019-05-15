function [X,Y,Z] = fib_sphere(N, normz_style)

% Inspired from: 
%     https://stackoverflow.com/questions/9600801
%     /evenly-distributing-n-points-on-a-sphere

ind_vec = 1:N; 
offset = 2/N; 
dPhi = pi * (3 - sqrt(5)); 

Y = (ind_vec - 1)*offset - 1 + offset/2; 
R = sqrt(1 - Y.^2); 
Phi = mod(ind_vec,N) * dPhi;

X = R .* cos(Phi);
Z = R .* sin(Phi); 

X = X'; 
Y = Y'; 
Z = Z';

if nargin == 1
    return;
end

normz_by = spherical_distance_matrix(X, Y, Z, normz_style);
normz_by = min(normz_by(normz_by > 0), [], 'all'); 

X = X/normz_by; 
Y = Y/normz_by; 
Z = Z/normz_by; 


end