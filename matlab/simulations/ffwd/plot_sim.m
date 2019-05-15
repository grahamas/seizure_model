clc; clear; close all; 
prm_folder = 'prm'; 
data_folder = 'data/ffwd'; 
func_folder = 'functions'; 
figr_folder = 'figures/ffwd'; 
addpath(prm_folder); 
addpath(func_folder);
addpath(data_folder); 
%%
calc_prm = struct();
calc_prm.bin_size = 50e-3; 
calc_prm.edge_lim = [0, 20]; 
calc_prm.smooth_size = 10; 
%%
load('combo_var.mat'); 
load('dat_001.mat');

num_neurons = length(data.Spike_Mon); 
num_pairs = num_neurons/2; 
P_nrn = {1:(num_pairs), (num_pairs+1):num_neurons}; 
cmaps = {autumn(num_pairs), winter(num_pairs)}; 

fig_PYR = figure; 
fig_PV = figure; 
figs = [fig_PYR, fig_PV]; 
arrayfun(@(x) set(x,'PaperOrientation','landscape','color','w'), figs);
fig_names = {'PYR', 'PV'}; 
%%
ratio_inp = 1; 
idx2plt = find(combos(:,4) == ratio_inp); 

%%
for i = 1:length(idx2plt) 
    idx_i = idx2plt(i); 
    combo_i = combos(idx_i,:); 
    ttl_i = sprintf('GE = %.2f & GI = %.2f & r = %.2f', ...
        combo_i(1), combo_i(2), combo_i(4)); 
    
    load(sprintf('dat_%03d', idx_i));
    spike_times = data.Spike_Mon;
    Isyn = data.Total_Isyn;
    
    psth = return_psth(data.Spike_Mon, calc_prm);
    centers = psth.centers;
    
    for j = 1:2
        figure(figs(j)); 
        subplot(3,3,i); hold on; 
        cmap = cmaps{j}*0.9;

        arrayfun(@(x) plot(centers, (x-1)*5 + psth.smoothed(P_nrn{j}(x),:),...
            'LineWidth',1,'Color',cmap(x,:)), 1:num_pairs);
        ylim([-10,100-(2-j)*20]); 
        xlabel('Time (s)'); 
        title([fig_names{j} ' - ' ttl_i], 'fontweight', 'normal');
        
    end
end
arrayfun(@(x,y) print(x, ...
    fullfile(figr_folder, sprintf('%s_ratio=%.2f.pdf',y{:},ratio_inp)),...
    '-dpdf', '-bestfit'), figs, fig_names) 

%%
figure;
for j = 1:2
    subplot(2,1,j); hold on;
    cmap = cmaps{j}*0.9;
    
    arrayfun(@(x) plot(centers, (x-1)*200 + psth.smoothed(P_nrn{j}(x),:),...
        'LineWidth',1,'Color',cmap(x,:)), 1:num_pairs);
    ttlj = fig_names{j};
    if j == 1
        ttlj = sprintf('%s - ramp decay ratio = 0.75', ttlj);
    end
    title(ttlj,'fontweight','normal'); 
    xlabel('Time (s)');
    ylabel('Rate (Hz) (shifted for clarity)');
    colormap(gca,cmap); 
    cbar = colorbar(gca, 'ticks', linspace(0,1,num_pairs), 'ticklabels', 1:num_pairs); 
    title(cbar, 'ordered pair #');
end