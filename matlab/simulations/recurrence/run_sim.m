%% RUNNING SIMULATION 

fprintf('Setting up simulation ... '); 
tic;

%% (A) LOAD PARAMETERS 

load('nrn_prm.mat'); 
exc_nrn = NRN_PRM.PYR; 
inh_nrn = NRN_PRM.PV; 

load('alphasyn_prm.mat'); 
exc_syn = SYN_PRM.AMPAR; 
inh_syn = SYN_PRM.GABAAR;

load('vmfilt_prm.mat'); 

clear NRN_PRM SYN_PRM; 

%% (B) SIMULATION TIME PARAMETERS 

simt = set_up.tstop; 
dt   = set_up.dt; 

T    = 0:dt:simt;
lenT = length(T); 

Tsec = T/1000; 

%% (C) DEFINE NEURON POPULATION AND NETWORK ARCHITECTURE

% 1. General parameter and network architecture 
net_arch    = NetworkArchitecture(...
    set_up.num_neurons, ...
    set_up.prob_e, ...
    set_up.spatial_distribution, ...
    set_up.weight_prm);

num_neurons = net_arch.num_neurons; % in case this got re-assigned 
V_init      = set_up.V_init; 

PE = net_arch.pop_ind.PE; 
PI = net_arch.pop_ind.PI; 

% 2. Intrinsic constant parameters  
run set_intrinsic_constants.m

% 3. Convert refractory period from time to step number (k)
d_APk = d_APt/dt;
 
%% (D) DEFINE SYNAPTIC PARAMETERS 

% 1. Synpatic conductance matrices 
[GE, GI] = net_arch.set_synaptic_conductances(set_up.Gsyn, set_up.syn_scale_type);

% 2. Synaptic constant parameters 
run set_synaptic_constants.m

% 3. Convert synaptic delay from time to step number (k)
del_e = delay_S_e/dt; 
del_i = delay_S_i/dt; 

%% (E) EXTERNAL CURRENT

I_app = zeros(num_neurons, lenT);  

% 1. Template 
% TODO: NEED TO UPDATE for generalization 
I_template = template_rampthendecay(T, set_up.fact_durramp, set_up.fact_decay);

% 2. Specific input to random neighbors 
centr_ind = net_arch.centered_neuron.ind; 
neigh_ind = net_arch.pick_random_neighbors(set_up.num_stimulated-1,'center'); 
stimulated_ind = [centr_ind, neigh_ind]; 

for i = stimulated_ind
    I_app(i,:) = set_up.Iapp_max * I_template;
end

%% (F) INITIALIZATION 

% 1. Initilize for storage and access
V = zeros(num_neurons, lenT);       % membrane potential % consider not save later in large net
AP = zeros(num_neurons, lenT);      % spike timings 

Xe = zeros(num_neurons, lenT);      % activation of exc syn
Xi = zeros(num_neurons, lenT);      % acttvation of inh syn 

I_syns = zeros(num_neurons,lenT);   % total synaptic currents 

% 2. Initial conditions of simulated variables  
t = 0;                                  % time  
k = 1;                                  % step number 
p = 1;                                  % dummy variable for AP saving 

v = V_init;                             % current V:    V[k]
v_km1 = v;                              % previous V:   V[k-1]
n = sigmoid_func(v, Vn_half, kn);       % K chan activation variable 

vs = v;                                 % slow V:       Vs[k] 

vf_km1 = zeros(num_neurons,1);          % fast V:       Vf[k-1]
vf_km2 = vf_km1;                        % fast V:       Vf[k-2]

se = 0;                                 % exc synapse 
ze = 0;                                 % ze = dse/dt
si = 0;                                 % inh synapse 
zi = 0;                                 % zi = dsi/dt 

k_prev = -d_APk*ones(num_neurons,1);    % prev step with spike 

elapsed_setup = toc; 
fprintf('took %.3f seconds. \n', elapsed_setup); 

%% (G) START SIMULATION 

fprintf('Running simulation ... '); 
tic

while (t < simt)
    % Save V at beginning 
    V(:,k) = v;   
    
    if k>1
        % Highpass V for detecting spike 
        dvf = (v-v_km1) - vf_km1*dt/tau_Vf;
        vf_k = vf_km1 + dvf; 
    end
   
    if k>2
        % Spikes and save synaptic activation 
        
        % These are neurons with spikes 
        cond_spk =  vf_km1 > APVf_thr & ... % prev Vf crosses threshold 
                    vf_km1 >= vf_km2 & ...  % Vf[k-1] >= Vf[k-2]
                    vf_km1 >= vf_k & ...    % Vf[k-1] >= Vf[k]
                    k - k_prev > d_APk;     % spikes can't happen within a certain time
                
        % Save spikes and update step with spikes 
        AP(cond_spk,p) = k; 
        
        % p doesn't really matter (sort of like k)
        % it just to keep the columns separated 
        p = p + 1;  
        
        k_prev(cond_spk) = k; 

        % AMPAR delayed activation 
        if k+del_e < lenT
            Xe(:,k+del_e) = GE*cond_spk; 
        end
        
        % GABAAR delayed activation 
        if k+del_i < lenT
            Xi(:,k+del_i) = GI*cond_spk; 
        end
        
        vf_km2 = vf_km1;                      % Vf[k-2] <- Vf[k-1]
    end
    
    if k > 1 
        vf_km1 = vf_k;  % Vf[k-1] <- Vf[k]                       
        v_km1 = v;      % V[k-1]  <- V[k]     
    end
    
    % Intrinsic variables
    m_inf = sigmoid_func(v, Vm_half, km);
    n_inf = sigmoid_func(v, Vn_half, kn);
    
    % AMPAR ODE 
    dse = dt*ze; 
    dze = alpha_S_e*Xe(:,k) + dt*(beta_S_e*ze + gamma_S_e*se); 
    % The driving force for AMPAR is from slow V (Vs)
    % like how they are further to soma 
    I_syn_e = se.*(E_S_e - vs); 
    
    % GABAAR ODE 
    dsi = dt*zi;
    dzi = alpha_S_i*Xi(:,k) + dt*(beta_S_i*zi + gamma_S_i*si);
    % The driving fource for GABAAR is taken with V
    % like how they are closer to soma 
    I_syn_i = si.*(E_S_i - v); 
    
    % Input current = Synaptic + External 
    % scaled by surface area of the neurons 
    I_ext = I_app(:,k)./SA; 
    I_syn = (I_syn_e + I_syn_i)./SA;
    
    I_syns(:,k) = I_syn; 
    
    % ODE for intrinsic variables 
    dn = dt*(n_inf - n)./taun; 
    dv = (dt./C).*( g_L.*(E_L - v) + ...
                    g_Na_max.*m_inf.*(E_Na - v) + ...
                    g_K_max.*n.*(E_K - v) + ...
                    I_ext + I_syn); 
    
    dvs = (v - vs)*dt/tau_Vs;
    
    % Update for next time step     
    % time and step 
    t = t + dt; 
    k = k + 1;
    
    % intrinsic 
    n = n + dn; 
    v = v + dv;
    
    vs = vs + dvs;
    
    % synaptic     
    se = se + dse;
    ze = ze + dze;     
    si = si + dsi;
    zi = zi + dzi; 
    
end

elapsed_sim = toc; 
fprintf('took %.3f seconds. \n', elapsed_sim); 

%% (H) EXTRACT SPIKE TIMES AND RATE (unit = second)

fprintf('Saving data ...'); 
tic; 

Spike_Times = cell(num_neurons,1); 
for i = 1:num_neurons
    api = AP(i,:); 
    Spike_Times{i} = sort(api(api~=0)*dt/1000); 
end

PSTH = return_psth(Spike_Times, set_up.rate_prm);
est_time = PSTH.centers;
est_rate = PSTH.smoothed; 


%% (I) SAVE DATA 

data = struct();

if num_neurons < 50 % for memory, will consider subsampling later
    data.InputCurrent = I_app;
    data.Tsec = Tsec;
    data.V = V;
end

data.Spike_Times = Spike_Times; 
data.Total_Isyn = sum(I_syns,1);  
data.Rate = struct('rate', est_rate, 'time', est_time); 
data.Stim_Ind = stimulated_ind; 

save(fullfile(set_up.data_folder, [set_up.file_pref '.mat']), ...
    'data', 'net_arch', 'set_up'); 

elapsed_save = toc; 
fprintf('took %.3f seconds. \n', elapsed_save); 

%% (J) CREATE VIDEO FOR RATE 

fprintf('Creating movie ...'); 
tic; 

vid_name = fullfile(set_up.data_folder, [set_up.file_pref '_rate']); 
net_arch.create_activity_movie(vid_name, est_time, est_rate, Tsec, I_app, stimulated_ind); 

elapsed_vid = toc; 
fprintf('took %.3f seconds. \n', elapsed_vid); 
