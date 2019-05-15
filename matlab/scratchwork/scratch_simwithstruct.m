%% Add paths 
clc; clear; %close all; 
prm_folder = 'prm'; 
data_folder = 'data'; 
func_folder = 'functions'; 
addpath(prm_folder); 
addpath(func_folder); 

load('nrn_prm.mat'); 
exc_nrn = NRN_PRM.PYR; 
inh_nrn = NRN_PRM.PV; 
clear NRN_PRM; 

load('alphasyn_prm.mat'); 
% load('doubleexpsyn_prm.mat');  
exc_syn = SYN_PRM.AMPAR; 
inh_syn = SYN_PRM.GABAAR;  %#ok<NASGU>

%% Simulation time parameters
simt=20000; % ms 
dt=1/100;
T=0:dt:simt;
lenT = length(T); 

Tsec = T/1000; 
%% Define neurons 
N_nrn = 6;
prob_e = 0.5;
V_init = -60; 

Ne = ceil(prob_e*N_nrn); 
Ni = N_nrn - Ne; 

Pe = 1:Ne; 
Pi = (Ne+1):N_nrn; 

lst_nrn_prm = fieldnames(exc_nrn); 
nrn_prm = struct(); 
for i = 1:length(lst_nrn_prm)
    prm_i = lst_nrn_prm{i};
    tmp_i = zeros(N_nrn,1); 
    tmp_i(Pe) = exc_nrn.(prm_i); 
    tmp_i(Pi) = inh_nrn.(prm_i);
    
    nrn_prm.(prm_i) = tmp_i; 
end
clear prm_i exc_nrn inh_nrn

%% Define synapses and connectivity 
lst_syn_prm = fieldnames(exc_syn); 
syn_prm = struct(); 
for i = 1:length(lst_syn_prm)
    prm_i = lst_syn_prm{i};
    syn_prm.(sprintf('%s_e', prm_i)) = exc_syn.(prm_i);
    syn_prm.(sprintf('%s_i', prm_i)) = inh_syn.(prm_i);
end

clear prm_i exc_syn inh_syn

del_e = syn_prm.delay_S_e/dt; 
del_i = syn_prm.delay_S_i/dt; 


% http://graphonline.ru/en/

Emat = [ ...
	 0     0     0     0     0     0
     0.1   0   0     0     0     0
     0     0.1   0     0     0     0
     0     0     0     0     0     0
     0.1   0     0     0     0     0
     0     0.1   0     0     0     0] * 70; 
Imat = [ ...
	 0     0     0     1     0     0
     0     0     0     0     1     0
     0     0     0     0     0     1
     0     0     0     0     0     0
     0     0     0     0     0     0
     0     0     0     0     0     0] * 3; 


%% Initialization 
V = zeros(N_nrn, lenT); 
AP = zeros(N_nrn, lenT); 

V(:,1) = V_init;
n = sigmoid_func(V(:,1), nrn_prm.Vn_half, nrn_prm.kn);

Xe = zeros(N_nrn, lenT); 
Xi = zeros(N_nrn, lenT); 

I_syns = zeros(N_nrn,lenT); 
ge_syns = zeros(N_nrn,lenT); 
gi_syns = zeros(N_nrn,lenT); 

%% External current 
I_app = zeros(N_nrn, lenT);

tmp_ramp_decay = zeros(1, lenT); 
dur_ramp = ceil(4*lenT/5);
tmp_ramp_decay(1:dur_ramp) = linspace(0,1,dur_ramp); 
tmp_ramp_decay(dur_ramp+1:end) = exp(-(0:(lenT-dur_ramp-1))/(T(end))); 

I_template = 700*tmp_ramp_decay; 

decay = 0.5; 
I_app(1,:) = I_template; 
I_app(4,:) = I_template; 

I_app(2,:) = decay*I_template; 
I_app(5,:) = decay*I_template; 

I_app(3,:) = decay^2*I_template; 
I_app(6,:) = decay^2*I_template; 
 
%% Other parameters 
APVf_thr = 20; 
d_APt = 1.5; 
d_APk = d_APt/dt;
k_prev = -d_APk*ones(N_nrn,1);

F=0.2; % 0.2/ms = 200Hz 
tauF=1/(2*pi*F);

Fslow = 0.01; % 0.01/ms = 10Hz 
tauSl = 1/(2*pi*Fslow); 
Vs = V;
%% Simulation 
tic

t=0;
k=1;
p=ones(N_nrn,1);

v = V(:,1);
vs = Vs(:,1); 
v_km1 = V(:,1); 

vf_km1 = zeros(N_nrn,1); 
vf_km2 = vf_km1;

se = 0;
ze = 0;
si = 0;
zi = 0; 

while (t < simt)
    V(:,k) = v;   
    Vs(:,k) = vs; 
    dvs = (v - vs)*dt/tauSl;
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
        
        p = p + 1;        
        
        vf_km2 = vf_km1;
    end
    
    if k > 1 
        vf_km1 = vf_k; 
        v_km1 = v; 
    end
    
    m_inf = sigmoid_func(v, nrn_prm.Vm_half, nrn_prm.km);
    n_inf = sigmoid_func(v, nrn_prm.Vn_half, nrn_prm.kn);
    
    dse = dt*ze; 
%     dze = dt*(beta_S_e*Xe(:,k) - 2*beta_S_e*ze - beta_S_e*beta_S_e*se); 
%     dze = beta_S_e*Xe(:,k) + dt*(-2*beta_S_e*ze - beta_S_e*beta_S_e*se); 
    dze = syn_prm.alpha_S_e*Xe(:,k) + dt*(syn_prm.beta_S_e*ze + syn_prm.gamma_S_e*se); 
    I_syn_e = se.*(syn_prm.E_S_e - vs); 
    
    dsi = dt*zi;
%     dzi = dt*(beta_S_i*Xi(:,k) - 2*beta_S_i*zi - beta_S_i*beta_S_i*si);
    dzi = syn_prm.alpha_S_i*Xi(:,k) + dt*(syn_prm.beta_S_i*zi + syn_prm.gamma_S_i*si);
    I_syn_i = si.*(syn_prm.E_S_i - v); 
    
    I_ext = I_app(:,k)./nrn_prm.SA; 
    I_syn = (I_syn_e + I_syn_i)./nrn_prm.SA;
    
    I_syns(:,k) = I_syn; 
    ge_syns(:,k) = se;
    gi_syns(:,k) = si; 
    
    dn = dt*(n_inf - n)./nrn_prm.taun; 
    dv = (dt./nrn_prm.C).*( nrn_prm.g_L.*(nrn_prm.E_L - v) + ...
                    nrn_prm.g_Na_max.*m_inf.*(nrn_prm.E_Na - v) + ...
                    nrn_prm.g_K_max.*n.*(nrn_prm.E_K - v) + ...
                    I_ext + I_syn); 
                

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

%%
figure; 
set(gcf, 'PaperOrientation','landscape','color','w');
axset_1 = gobjects(N_nrn*2,1); 
for i = 1:N_nrn
    axset_1(i*2-1) = subplot(N_nrn, 2, i*2-1); hold on
    
    plot(Tsec, V(i,:), '-k', 'linewidth', 0.5);
    api = AP(i,:); 
    api = api(api~=0); 
   
    plot(api*dt/1000,20*ones(length(api),1),'.r');
    ylim([-90, 50]); 
    xlabel('Time (s)'); 
    ylabel(sprintf('Neuron %d (mV)', i)); 
    
    axset_1(i*2) = subplot(N_nrn, 2, i*2); hold on; 
    plot(Tsec, I_app(i,:), '-k', 'linewidth', 1.2);
    title(sprintf('Current to neuron %d',i))
    grid on 
    ylim([0, 700]); 
end

linkaxes(axset_1,'x'); 
