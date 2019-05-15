%% Add paths 
clearvars -except file_counter GE_max GI_max Iinp_max Inp_decay combos

prm_folder = 'prm'; 
data_folder = 'data/ffwd'; 
func_folder = 'functions'; 
addpath(prm_folder); 
addpath(func_folder); 

load('nrn_prm.mat'); 
exc_nrn = NRN_PRM.PYR; 
inh_nrn = NRN_PRM.PV; 
clear NRN_PRM; 

load('alphasyn_prm.mat'); 
exc_syn = SYN_PRM.AMPAR; 
inh_syn = SYN_PRM.GABAAR;  %#ok<NASGU>

%% Simulation time parameters
simt=20000; % ms 
dt=1/100;
T=0:dt:simt;
lenT = length(T); 

Tsec = T/1000; 

%% Define neurons 
N_nrn = 20;
prob_e = 0.5;
V_init = -60; 

N_pairs = N_nrn/2; 

Ne = ceil(prob_e*N_nrn); 
Ni = N_nrn - Ne; 

Pe = 1:Ne; 
Pi = (Ne+1):N_nrn; 

lst_nrn_prm = fieldnames(exc_nrn); 
for i = 1:length(lst_nrn_prm)
    prm_i = lst_nrn_prm{i};
    tmp_i = zeros(N_nrn,1); 
    tmp_i(Pe) = exc_nrn.(prm_i); 
    tmp_i(Pi) = inh_nrn.(prm_i); 
    eval(sprintf('%s = tmp_i;', prm_i));
end
clear prm_i exc_nrn inh_nrn

%% Define synapses and connectivity 
lst_syn_prm = fieldnames(exc_syn); 
for i = 1:length(lst_syn_prm)
    prm_i = lst_syn_prm{i};
    eval(sprintf('%s_e = exc_syn.%s;', prm_i, prm_i));    
    eval(sprintf('%s_i = inh_syn.%s;', prm_i, prm_i));
end

clear prm_i exc_syn inh_syn

del_e = delay_S_e/dt; 
del_i = delay_S_i/dt; 

[Emat, Imat] = template_ffwd_pair_synmat(N_nrn); 

%% External current template 
I_template = template_rampthendecay(T, 4/5, 1);

%% LP and HP filter parameters for Vm 
APVf_thr = 20; 
d_APt = 1.5; 
d_APk = d_APt/dt;

F=0.2; % 0.2/ms = 200Hz 
tauF=1/(2*pi*F);

Fslow = 0.01; % 0.01/ms = 10Hz 
tauSl = 1/(2*pi*Fslow); 

%% Update synaptic conductance 
Emat = GE_max*Emat; 
Imat = GI_max*Imat; 

%% Update external current 
I_app = zeros(N_nrn, lenT);  

for i = 1:N_pairs
    Iimax = Iinp_max * (Inp_decay^(i-1)); 
    I_app(i,:) =  Iimax * I_template;      
    I_app(i+N_pairs,:) =  Iimax * I_template; 
end
 
%% Initialization 
V = zeros(N_nrn, lenT); 
AP = zeros(N_nrn, lenT); 

V(:,1) = V_init;
n = sigmoid_func(V(:,1), Vn_half, kn);

Xe = zeros(N_nrn, lenT); 
Xi = zeros(N_nrn, lenT); 

I_syns = zeros(N_nrn,lenT); 

k_prev = -d_APk*ones(N_nrn,1);

%% Simulation 
tic

t=0;
k=1;
p=1;

v = V(:,1);
v_km1 = V(:,1); 
vs = v;

vf_km1 = zeros(N_nrn,1); 
vf_km2 = vf_km1;

se = 0;
ze = 0;
si = 0;
zi = 0; 

while (t < simt)
    V(:,k) = v;   
    
    if k>1
        dvf = (v-v_km1) - vf_km1*dt/tauF;
        vf_k = vf_km1 + dvf; 
    end
   
    if k>2
        cond_spk =  vf_km1 > APVf_thr & ...
                    vf_km1 >= vf_km2 & ...
                    vf_km1 >= vf_k & ...
                    k - k_prev > d_APk;
        AP(cond_spk,p) = k; 
        k_prev(cond_spk) = k; 

        if k+del_e < lenT
            Xe(:,k+del_e) = Emat*cond_spk; 
        end
        
        if k+del_i < lenT
            Xi(:,k+del_i) = Imat*cond_spk; 
        end
        
        % actually would need a vector but doesnt matter cuz 
        % AP keeps track of the time, position doesnt matter 
        % and AP doesnt affect the integration 
        p = p + 1;        
        
        vf_km2 = vf_km1;
    end
    
    if k > 1 
        vf_km1 = vf_k; 
        v_km1 = v; 
    end
    
    m_inf = sigmoid_func(v, Vm_half, km);
    n_inf = sigmoid_func(v, Vn_half, kn);
    
    dse = dt*ze; 
    dze = alpha_S_e*Xe(:,k) + dt*(beta_S_e*ze + gamma_S_e*se); 
    I_syn_e = se.*(E_S_e - vs); 
    
    dsi = dt*zi;
    dzi = alpha_S_i*Xi(:,k) + dt*(beta_S_i*zi + gamma_S_i*si);
    I_syn_i = si.*(E_S_i - v); 
    
    I_ext = I_app(:,k)./SA; 
    I_syn = (I_syn_e + I_syn_i)./SA;
    
    I_syns(:,k) = I_syn; 
    
    dn = dt*(n_inf - n)./taun; 
    dv = (dt./C).*( g_L.*(E_L - v) + ...
                    g_Na_max.*m_inf.*(E_Na - v) + ...
                    g_K_max.*n.*(E_K - v) + ...
                    I_ext + I_syn); 
    
    dvs = (v - vs)*dt/tauSl;
    
    n = n + dn; 
    v = v + dv;
    t = t + dt; 
    k = k + 1;
    
    vs = vs + dvs;
    
    se = se + dse;
    ze = ze + dze;     
    si = si + dsi;
    zi = zi + dzi; 
    
end
toc

%% Saving spikes 
Spike_Mon = cell(N_nrn,1); 
for i = 1:N_nrn
    api = AP(i,:); 
    Spike_Mon{i} = api(api~=0)*dt/1000; 
end

%% Saving data 
data = struct();
data.Spike_Mon = Spike_Mon; 
data.Total_Isyn = sum(I_syns,1);  

data.vars = struct(...
    'GE_max', GE_max, ...
    'GI_max', GI_max, ...
    'Iinp_max', Iinp_max, ...
    'Inp_decay', Inp_decay); 

% save(fullfile(data_folder, sprintf('dat_%03d', file_counter)), 'data');