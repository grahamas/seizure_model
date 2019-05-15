[X,Y,Z] = fib_sphere(1000,'arc');

hemi_ind = zeros(size(Z)); 
hemi_ind(Z >= 0) = +1; % upp
hemi_ind(Z <  0) = -1; % low 

[~, ind_zmax] = max(Z);

R_est = max(sqrt(X.^2 + Y.^2 + Z.^2), [], 'all');
proj_X = R_est * X ./ (R_est + abs(Z)); 
proj_Y = R_est * Y ./ (R_est + abs(Z)); 

n_split = 8; 
cmap = parula(n_split); 
edges_Z = linspace(min(Z), max(Z), n_split + 1); 
binned_Z = discretize(Z, edges_Z); 

%%
figure; scatter3(X, Y, Z); daspect([1,1,1]); xlabel('x');ylabel('y');zlabel('z');
%%
figure; 
subplot(121); hold on;
scatter(proj_X(ind_zmax), proj_Y(ind_zmax), 30, 'r');
for i = 1 : n_split 
    ind2plt = binned_Z == i & hemi_ind == 1; 
    scatter(proj_X(ind2plt), proj_Y(ind2plt), 10, cmap(i,:), 'filled');
end
daspect([1,1,1]);

subplot(122); hold on;
for i = 1 : n_split 
    ind2plt = binned_Z == i & hemi_ind == -1; 
    scatter(proj_X(ind2plt), proj_Y(ind2plt), 10, cmap(i,:), 'filled');
end
daspect([1,1,1]);

%%
figure; hold on;
arrayfun(@(xi) scatter(ones(size(Z(binned_Z == xi))), ...
    Z(binned_Z == xi), 10, cmap(xi, :), 'filled'), 1:n_split);

