function [lat, ind] = lattice_4E1I_template

lat = return_combination([-0.5,0.5], [-0.5,0.5]); 
lat = vertcat(lat, [0,0]); 

ind = [ones(4,1);-1];

end