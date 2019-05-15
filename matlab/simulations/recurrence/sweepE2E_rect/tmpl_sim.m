%% Initialize simulation 

%% Adding paths 
run essential_startup.m

%% File 
% data_folder:  for storage 
% file_pref:    file prefix 
%               * remember to change for each simulation 
set_up.data_folder  = fullfile(set_up.head_dir, 'data/rec'); 
set_up.file_pref    = 'test01';

%% Simulation time variables
% tstop:        stop time in [ms], assumed run from 0ms
% dt:           time step [ms] 
set_up.tstop = 20e3;    % ms  
set_up.dt = 1/10;       % ms 

%% Simulation neuron variables 
% num_neurons:      number of neurons
% prob_e:           portion of excitatory (PYR) neurons
% V_init:           initial condition for all membrane potentail 
set_up.num_neurons = 900; 
set_up.prob_e = 0.8;    
set_up.V_init = -60;   

%% Spatial distribution of neurons 
% spatial_distribution:     how to set up the spatial distribution 
% type: either 'rect' or 'sphere'
set_up.spatial_distribution = struct();

% Either of these options 
% 1. Rectangular 2D 
%   size:   number of points in X axis x number of points in Y axis 
    set_up.spatial_distribution.type = 'rect'; 
    set_up.spatial_distribution.size = [30, 30]; % this depends on num_neurons 
    
% 2. Spherical Fibonnaci latice 3D 
%   norm:   how to normalize the distance between points
%           'arc':  normalize by smallest arc length on the sphere surface
%           'eucl': by the smallest euclidean distance 
%     set_up.spatial_distribution.type = 'sphere'; 
%     set_up.spatial_distribution.norm = 'arc'; 


%% Simulation synaptic variables 

% weight_prm:   weight (S) parameters (strength to scale to conductances) 
% type:         type of spatial-fall off
%               'exp':      m*exp(-d / k)
%               'gauss':    m*exp(-d^2 / k)
%               'rect':     m 
% k:            decay factor, smaller means faster 
%               * error if k = inf and type ~= 'rect' 
% m:            [optional] just a scalar factor times the weight 
%               [default = 1] 
% bound_weight: [optional] 2-element vector bound of weight (strength)
%               anything below is set to lower bound, anything above is set
%               to upper bound. 
%               [default = [0,1]] 
% dist_range:   [optional] 2-element vector bound of distance 
%               anything out of the distance range is set to `def_s`
%               [default = [0, inf]]
% def:          [optional] default weight (strength) value if the distance
%               is out of `dist_range`
%               [default = 0] 

set_up.weight_prm = struct(); 
set_up.weight_prm.EtoE = struct('k', 10, 'type', 'gauss', 'dist_range', [0, 5]);
set_up.weight_prm.EtoI = struct('k', 10, 'type', 'gauss'); 
set_up.weight_prm.ItoE = struct('k', 30, 'type', 'gauss'); 
set_up.weight_prm.ItoI = struct('k', 30, 'type', 'gauss'); 

% syn_scale_type:   scaling factor 
%                   'unity':  no scaling 
%                   'linear': scaled by 1/N
%                   'sqrt':   scaled by 1/sqrt(N)
set_up.syn_scale_type = 'sqrt'; 

% Gsyn:         maximal synaptic conductance for different connectivity
%               G = Gmax * S / scaled
set_up.Gsyn = struct();
set_up.Gsyn.EtoE = 15; 
set_up.Gsyn.EtoI = 10;
set_up.Gsyn.ItoE = 3;
set_up.Gsyn.ItoI = 1;


%% External input
% Iapp_max:         maximal applied current input amplitude 
% fact_durramp:     factor of simulation time for ramp-up phase 
% fact_decay:       decay factor for exponential decay after, 
%                   meaning smaller -> faster
set_up.Iapp_max       = 700; 
set_up.fact_durramp   = 3/5;
set_up.fact_decay     = 0.7;  

% num_stimulated:   number of neurons to stimulate around the centered one 
percent_stim = 0.03; 
set_up.num_stimulated = ceil(percent_stim*set_up.num_neurons);  

%% Estimated rate 
% bin_size:     for binning to count spikes [second]
% edge_lim:     the edge limit to count within [second]
% smooth_size:  number of points to perform gaussian smoothing [points]
set_up.rate_prm = struct();        % all in seconds here 
set_up.rate_prm.bin_size = 20e-3;  
set_up.rate_prm.edge_lim = [0, set_up.tstop]*1e-3; 
set_up.rate_prm.smooth_size = 10;  % number of points 

%% Simulate 
clearvars -except set_up

run run_sim.m

