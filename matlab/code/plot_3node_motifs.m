clc; clear; close all;

addpath(genpath('../functions')); 

%% Create profile
g3wd = sortrows(return_combination([-1,0,1], 'num', 6)); 

g3wd_inbase3 = g3wd + 1; % no negative  
g3wd_inbase3 = base2dec(num2str(g3wd_inbase3, '%d'),3); 
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
ncols = ceil(sqrt(max_id)); 
nrows = ceil(max_id/ncols); 

figure; 
normz_pos = [0,0,1,1]; 
set(gcf, 'Unit', 'normalized', 'Position', normz_pos, ...
    'PaperUnits', 'centimeters','PaperSize', 40*[1,normz_pos(4)/normz_pos(3)],...
    'PaperPosition', [0,0,1,normz_pos(4)/normz_pos(3)]*40,...
    'InvertHardcopy', 'off', ...
    'Color', 'w');

for i = 1:max_id     
    idx_id = find(ids == i, 1);
    gi = zeros(3,3);     
    gi([2:4, 6:8]) = g3wd(idx_id,:);    
    gri = digraph(gi);
    
    subplot(nrows, ncols, i);
    gwi = gri.Edges.Weight; 
    clrs = zeros(length(gwi), 3); 
    clrs(gwi < 0, 1) = 1;
    clrs(gwi > 0, 3) = 1;
    h = plot(gri, 'EdgeColor', clrs);     
    h.XData = [-1, 0, 1]; 
    h.YData = [0, sqrt(3), 0];
    h.NodeLabel = {};
    h.NodeColor = [0,0,0];
    daspect([1,1,1]);
    text(-1.5,sqrt(3), num2str(i))
    set(gca, 'visible', 'off'); 
end

print(gcf, '3nmotifs_dirwei.pdf', '-dpdf', '-painters');
disp('Saved'); 

%% Plot a random motif and the corresponding isomorphic graphs 
% id = 106 for ffw_inh 
% id = 114 for fb_inh 

% rnd_id = randi(max_id); 
rnd_id = 114;
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
    h.NodeColor = [0.2,0.2,0.2];
    h.NodeLabel = {};
    daspect([1,1,1]);
    text(-1.1,sqrt(3)*2/3, num2str(rnd_id))
end

