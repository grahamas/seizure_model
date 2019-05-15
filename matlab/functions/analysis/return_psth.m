function psth = return_psth(spike_times, calc_prm)
if ~iscell(spike_times)
    error('`spike_times` must be a cell array'); 
end

if ~all(cellfun(@(x) isvector(x) && isnumeric(x), spike_times, 'uni', 1))
    error('Each of the element in `spike_times` needs to be a numeric vector');
end

try
    bin_sz = calc_prm.bin_size;
    edge_lim = calc_prm.edge_lim;
    smooth_win = calc_prm.smooth_size;
catch 
    error(['The `calc_prm` needs to be a struct that has these fields: ' ...
        'bin_size, edge_lim, smooth_size']);
end

nbins = ceil(abs(diff(edge_lim))/bin_sz); 
edges = linspace(edge_lim(1), edge_lim(2), nbins + 1); 
centers = (edges(1:end-1) + edges(2:end))/2; 
    
binned_psth = cellfun(@(x) histcounts(x(:), edges)/bin_sz, spike_times, 'uni', 0); 
smooth_psth = cellfun(@(x) smoothdata(x,'gaussian',smooth_win), binned_psth, 'uni', 0);  

psth = struct(); 
psth.binned = vertcat(binned_psth{:}); 
psth.smoothed = vertcat(smooth_psth{:}); 
psth.centers = centers;

end