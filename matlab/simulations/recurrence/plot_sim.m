%% Plotting simulation 
% run essential_startup.m
file_name = sweep_master.files{idx2play}; 
load(file_name); 

PE = net_arch.pop_ind.PE; 
PI = net_arch.pop_ind.PI;
stim_ind = data.Stim_Ind; 
spike_times = data.Spike_Times;

clrs = {[0,0.1,0.7],[0.9,0,0]}; 
clr_ind = zeros(net_arch.num_neurons,1); 
clr_ind(PE) = 1; 
clr_ind(PI) = 2; 

rate = data.Rate.rate; 
t_rate = data.Rate.time; 

dt = set_up.dt*1e-3; 
tstop = set_up.tstop*1e-3; 
V = data.V;
t_V = 0:dt:tstop;
%%
figure; hold on; 
cellfun(@(x,y,z) scatter(x, y*ones(size(x)), 10, clrs{clr_ind(z)}, 'filled', 'o'), ...
    spike_times(stim_ind)', num2cell(1:length(stim_ind)), num2cell(stim_ind))
%%
figure; 
ax1=subplot(211); hold on; 
plot(t_rate, rate(PE,:), 'Color', clrs{1}); 
ax2=subplot(212); hold on;
plot(t_rate, rate(PI,:), 'Color', clrs{2});
linkaxes([ax1,ax2],'x')


%%
centr_ind = net_arch.centered_neuron.ind; 
dist2centr = net_arch.dist(centr_ind, :); 
[~, ordered_ind] = sort(dist2centr); 

GE = net_arch.syn_conductance.GE(ordered_ind, ordered_ind); 
GI = net_arch.syn_conductance.GI(ordered_ind, ordered_ind); 


%%

figure; 
 hold on; 
for i = 1:set_up.num_neurons
    spkti = spike_times{i}; 
    spkti = spkti(spkti < 5);
    ycoord = ordered_ind(i); 
    scatter(spkti, ycoord*ones(size(spkti)), 3, ...
        clrs{clr_ind(i)}, 'filled', 'o')

end

linkaxes(findobj(gcf, 'type', 'axes'), 'xy');

 