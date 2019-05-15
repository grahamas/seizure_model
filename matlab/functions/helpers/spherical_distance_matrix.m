function R = spherical_distance_matrix(X, Y, Z, dist_style) 

if contains(dist_style, 'eucl', 'IgnoreCase', 1) 
    R = euclidean_distance_matrix(X, Y, Z); 
elseif contains(dist_style, 'arc', 'IgnoreCase', 1) 
    R = sphere_arc_length_matrix(X, Y, Z); 
else 
    error('`dist_style` could either be "euclidean" or "arc length"');
end

end