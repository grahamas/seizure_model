function R = euclidean_distance_matrix(varargin)

if nargin < 2 || nargin > 3
    error('There could either be `X,Y,Z` or `X,Y` as input');
end

X = to_col_vec(varargin{1}); 
Y = to_col_vec(varargin{2}); 
ind_vec = 1:length(X); 

Z = zeros(size(X)); 
if nargin == 3 
    Z = varargin{3};
end

R = bsxfun(@(i,j) sqrt( (X(i)-X(j)).^2 + ...
                        (Y(i)-Y(j)).^2 + ...
                        (Z(i)-Z(j)).^2 ), ...
                       ind_vec, ind_vec');
                      
end
