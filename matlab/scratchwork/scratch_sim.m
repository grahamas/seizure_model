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
simt=10000; % ms 
dt=1/100;
T=0:dt:simt;
lenT = length(T); 

Tsec = T/1000; 
%% Define neurons 
N_nrn = 30;
prob_e = 0.8;
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
    eval(sprintf('%s = tmp_i;', prm_i));
%     nrn_prm.(prm_i) = tmp_i; 
end
clear prm_i exc_nrn inh_nrn

%% Define synapses and connectivity 
lst_syn_prm = fieldnames(exc_syn); 
syn_prm = struct(); 
for i = 1:length(lst_syn_prm)
    prm_i = lst_syn_prm{i};
    eval(sprintf('%s_e = exc_syn.%s;', prm_i, prm_i));    
    eval(sprintf('%s_i = inh_syn.%s;', prm_i, prm_i));
%     
%     syn_prm.(sprintf('%s_e', prm_i)) = exc_syn.(prm_i);
%     syn_prm.(sprintf('%s_i', prm_i)) = inh_syn.(prm_i);
end

clear prm_i exc_syn inh_syn

del_e = delay_S_e/dt; 
del_i = delay_S_i/dt; 

% Emat = [0,0;0,0]*20;
% Imat = [0,1;0,0]*2;

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

% Emat = [ ...
% 	 0     0     0     0
%      0.1   0     0     0
%      0.   0     0     0
%      0.1   0.     0     0  ] * 50; 
% Imat = [ ...
% 	 0     0     1     0
%      0     0     0     1
%      0     0     0     0
%      0     0     0     0] * 2; 

zero_self = 1-eye(N_nrn); 
Emat = 10*rand(N_nrn).*zero_self; 
Imat = 5*rand(N_nrn).*zero_self; 
%% Initialization 
V = zeros(N_nrn, lenT); 
AP = zeros(N_nrn, lenT); 

V(:,1) = V_init;
n = sigmoid_func(V(:,1), Vn_half, kn);

Xe = zeros(N_nrn, lenT); 
Xi = zeros(N_nrn, lenT); 

I_syns = zeros(N_nrn,lenT); 
ge_syns = zeros(N_nrn,lenT); 
gi_syns = zeros(N_nrn,lenT); 

%% External current 
I_app = zeros(N_nrn, lenT);

% I_app(1,T > 0.2e3 & T < 0.3e3) = 50; 
% I_app(2,T > 0.25e3 & T < 0.7e3) = 50; 
% I_app(T > 0.2e3 & T < 0.3e3) = 50; 
% I_app = linspace(0,1000,lenT); 

tmp_triangle = zeros(1, lenT); 
tmp_triangle(1:ceil(lenT/2)) = linspace(0,1,ceil(lenT/2)); 
tmp_triangle(ceil(lenT/2):end) = linspace(1,0,ceil(lenT/2)); 

tmp_ramp = linspace(0,1,lenT); 

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
 
% I_app(1,:) = 400*I_template; 
% I_app(3,:) = 400*I_template; 
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
%     Vs(:,k) = vs; 
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
        
        p(cond_spk) = p(cond_spk) + 1;        
        
        vf_km2 = vf_km1;
    end
    
    if k > 1 
        vf_km1 = vf_k; 
        v_km1 = v; 
    end
    
    m_inf = sigmoid_func(v, Vm_half, km);
    n_inf = sigmoid_func(v, Vn_half, kn);
    
    dse = dt*ze; 
%     dze = dt*(beta_S_e*Xe(:,k) - 2*beta_S_e*ze - beta_S_e*beta_S_e*se); 
%     dze = beta_S_e*Xe(:,k) + dt*(-2*beta_S_e*ze - beta_S_e*beta_S_e*se); 
    dze = alpha_S_e*Xe(:,k) + dt*(beta_S_e*ze + gamma_S_e*se); 
    I_syn_e = se.*(E_S_e - vs); 
    
    dsi = dt*zi;
%     dzi = dt*(beta_S_i*Xi(:,k) - 2*beta_S_i*zi - beta_S_i*beta_S_i*si);
    dzi = alpha_S_i*Xi(:,k) + dt*(beta_S_i*zi + gamma_S_i*si);
    I_syn_i = si.*(E_S_i - v); 
    
    I_ext = I_app(:,k)./SA; 
    I_syn = (I_syn_e + I_syn_i)./SA;
    
    I_syns(:,k) = I_syn; 
    ge_syns(:,k) = se;
    gi_syns(:,k) = si; 
    
    dn = dt*(n_inf - n)./taun; 
    dv = (dt./C).*( g_L.*(E_L - v) + ...
                    g_Na_max.*m_inf.*(E_Na - v) + ...
                    g_K_max.*n.*(E_K - v) + ...
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
% figure; 
% set(gcf, 'PaperOrientation','landscape','color','w');
% axset_1 = gobjects(N_nrn*2,1); 
% for i = 1:N_nrn
%     axset_1(i*2-1) = subplot(N_nrn, 2, i*2-1); hold on
%     
%     plot(Tsec, V(i,:), '-k', 'linewidth', 0.5);
%     api = AP(i,:); 
%     api = api(api~=0); 
%    
%     plot(api*dt/1000,20*ones(length(api),1),'.r');
%     ylim([-90, 50]); 
%     xlabel('Time (s)'); 
%     ylabel(sprintf('Neuron %d (mV)', i)); 
%     
%     axset_1(i*2) = subplot(N_nrn, 2, i*2); hold on; 
%     plot(Tsec, I_app(i,:), '-k', 'linewidth', 1.2);
%     title(sprintf('Current to neuron %d',i))
%     grid on 
%     ylim([0, 700]); 
% end
% 
% linkaxes(axset_1,'x'); 

% xlim([0,6]); 
% print('2p', '-dpdf', '-bestfit');
% print('only_ffw_e2i', '-dpdf', '-bestfit');
%% 
% figure; 
% plot(Tsec,Vs)
% xlim([0,6]); 
% legend; 
% 
% %% 
% for i = Pe
%     figure;
%     set(gcf,'color','w');
%     subplot(221); hold on
%     plot(Tsec, ge_syns(i,:));
%     plot(Tsec, -gi_syns(i,:));
%     title(['G_{syn} to neuron ' num2str(i)]);
%     legend('AMPA_R', 'GABAA_R');
%     xlim([0,6]); 
%     
%     subplot(223);
%     plot(Tsec, I_syns(i,:), '-k');
%     title('Total synaptic current');
%     xlabel('Time (s)');
%     xlim([0,6]); 
%     
%     subplot(222); hold on
%     plot(Tsec, ge_syns(i+Ne,:));
%     plot(Tsec, -gi_syns(i+Ne,:));
%     legend('AMPA_R', 'GABAA_R');
%     title(['G_{syn} to neuron ' num2str(i+Ne)]);
%     xlim([0,6]); 
%     
%     subplot(224);
%     plot(Tsec, I_syns(i+Ne,:), '-k');
%     title('Total synaptic current');
%     xlabel('Time (s)');
%     xlim([0,6]); 
% end
%%
% fN = (1/(dt*1e-3))/2; 
% f_band = [2, 50]; 
% [b,a]=butter(2,f_band/fN, 'bandpass');  
% pEEG=filter(b,a,sum(I_syns,1) + sum(I_app,1)*0);
% pEEG=-pEEG;    
% cvtv = linspace(0, max(Tsec) - 1, 100); 
% CV_pEEG = arrayfun(@(x) std(pEEG(Tsec >= x & Tsec < x+1))/mean(pEEG(Tsec >= x & Tsec < x+1)), ...
%     cvtv, 'uni', 1);
% %%
% figure; 
% subplot(121); plot(Tsec, pEEG);
% yyaxis right
% plot(cvtv, abs(CV_pEEG));
% subplot(122); 
% [s,f,t] = spectrogram(pEEG,2^18,2^17,2^12,(1000/dt));
% s = abs(s); 
% s = bsxfun(@rdivide, s, s(:,1));
% image(t,f,20*log10(s), 'cdatamapping', 'scaled')
