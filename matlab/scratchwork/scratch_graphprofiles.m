g3wd = sortrows(return_combination([-1,0,1], 'num', 6)); 
n_combs = size(g3wd,1);
ids = 1:n_combs;

all_perm = perms(1:3); 
n_perms = size(all_perm, 1); 

for i = 1:(n_combs - 1)
    gi = zeros(3,3); 
    gi([2:4, 6:8]) = g3wd(i,:);
    for j = (i + 1):n_combs
        gj = zeros(3,3); 
        gj([2:4, 6:8]) = g3wd(j,:);
        
        same_ij = 0; 
        for k = 1:n_perms
            perm_k = all_perm(k,:); 
            perm_j = gj(perm_k, perm_k); 
            if isequal(perm_j, gi)
                same_ij = 1; 
            end
        end
        
        if same_ij 
            ids(j) = ids(i);
        end
    end
end

[~, ~, ids] = unique(ids); 
max_id = max(ids); 

%% Plot all motifs 
nsplt = ceil(sqrt(max_id)); 

figure('unit', 'normalized', 'position', [0,0,1,1], ...
    'color', 'w', 'papersize', 30*[1.5,1]); 
for i = 1:max_id     
    idx_id = find(ids == i, 1);
    gi = zeros(3,3);     
    gi([2:4, 6:8]) = g3wd(idx_id,:);    
    gri = digraph(gi);
    
    subplot(nsplt, nsplt, i);
    gwi = gri.Edges.Weight; 
    clrs = zeros(length(gwi), 3); 
    clrs(gwi < 0, 1) = 1;
    clrs(gwi > 0, 3) = 1;
    h = plot(gri, 'EdgeColor', clrs);     
    h.XData = [-1, 0, 1]; 
    h.YData = [0, sqrt(3), 0];
    h.NodeLabel = {};
    daspect([1,1,1]);
    text(-1.2,sqrt(3)*4/5, num2str(i))
    set(gca, 'visible', 'off'); 
end

print(gcf, '3nmotifs_dirwei.pdf', '-dpdf', '-painters');
%% Plot a random motif and the corresponding isomorphic graphs 

rnd_id = 100;randi(max_id); 
idx_id = find(ids == rnd_id); 
nsplt = ceil(sqrt(length(idx_id))); 
figure;  
for i = 1:length(idx_id)
    gi = zeros(3,3); 
    gi([2:4, 6:8]) = g3wd(idx_id(i),:);
    gri = digraph(gi);
    subplot(nsplt, nsplt, i);
    gwi = gri.Edges.Weight; 
    clrs = zeros(length(gwi), 3); 
    clrs(gwi < 0, 1) = 1;
    clrs(gwi > 0, 3) = 1;
    h = plot(gri, 'EdgeColor', clrs); 
    h.XData = [-1, 0, 1]; 
    h.YData = [0, sqrt(3), 0];
    h.NodeLabel = {};
    daspect([1,1,1]);
    text(-1.1,sqrt(3)*2/3, num2str(rnd_id))
end

