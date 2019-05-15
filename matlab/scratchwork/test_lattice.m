lat_tmpl = return_combination([0,1], [0,1]); 
lat_tmpl = vertcat(lat_tmpl, [0.5,0.5]); 

ind_tmpl = [ones(4,1);-1];

clr_tmpl = [repmat([0,0,1], [4,1]); [1,0,0]]; 

% scatter(coord(:,1), coord(:,2), 100, clrs_pop, 'filled', 'o');

%%
N = 100; 

N = 5*ceil(sqrt(N/5))^2;
num_tmpl = ceil(N/5); 
num_side = ceil(sqrt(num_tmpl)); 

dist_majr = 2; 
axis_majr = 0:dist_majr:(num_side*dist_majr);  
axis_majr = axis_majr(1:num_side); 

lat_majr = return_combination(axis_majr, axis_majr); 

lat_finl = arrayfun(@(i) ...
    lat_tmpl + lat_majr(i,:), 1:size(lat_majr,1), 'uni', 0);
lat_finl = vertcat(lat_finl{:}); 

ind_finl = repmat(ind_tmpl, [num_tmpl, 1]); 
clr_finl = repmat(clr_tmpl, [num_tmpl, 1]); 
figure; hold on; 
scatter(lat_finl(:,1), lat_finl(:,2), 100, clr_finl, 'filled', 'o');
daspect([1,1,1]); set(gca, 'visible', 'off')
