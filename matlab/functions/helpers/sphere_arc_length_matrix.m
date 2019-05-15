function ArcLength = sphere_arc_length_matrix(X, Y, Z, C)
dist2cent_tol = 1e-10; 
if nargin < 4
    C = [0,0,0];
end

if length(C) ~= 3 || ~isvector(C)
    error('`C` needs to be the 3-d coordinate of the center');
end

X = to_col_vec(X) - C(1); 
Y = to_col_vec(Y) - C(2); 
Z = to_col_vec(Z) - C(3);

dist2cent = sqrt( X.^2 + Y.^2 + Z.^2 );

if any(abs(dist2cent(1) - dist2cent) > dist2cent_tol)
    error('The distances to center do not always the same');
end

% due to precision, get the maximum distance
% so "acos" won't return a complex number
R = max(dist2cent); 
R2 = R*R; 

theta_diff = acos( (X.*X' + Y.*Y' + Z.*Z') / R2); 

% because of R2 estimate, theta_diff not necessarily
% will be 0 at identity line 
zero_identity = 1 - eye(length(X)); 

ArcLength = R * theta_diff .* zero_identity; 

end