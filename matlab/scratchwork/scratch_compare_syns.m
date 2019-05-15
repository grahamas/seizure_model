dt = 1/100;
t = 0:dt:100; 
tau_alphasyn = 3; 
tau_r = 10; 
tau_d = 20; 

alpha_syn = (1/tau_alphasyn)*t.*exp(-t/tau_alphasyn); 
alpha_syn = alpha_syn/max(alpha_syn); 
exp2_syn = (exp(-t/tau_d) - exp(-t/tau_r)); 
% exp2_syn = exp2_syn/max(exp2_syn); 
t_peak = tau_r*tau_d*log(tau_d/tau_r)/(tau_d - tau_r); 
max_peak = (exp(-t_peak/tau_d) - exp(-t_peak/tau_r)); 
exp2_syn = exp2_syn/max_peak;
figure;
hold on; 
plot(t, alpha_syn); 
plot(t, exp2_syn);
xlim([0, 100]);

%%
spks = zeros(1,lenT); 
spks(AP(1,:) ~= 0) = 1; 
% spks(T < 1e4) = '';
figure; 
plot(spks,'.-')
ylim([-0.5, 2]);
first_spk = find(spks,1); 
last_spk = find(spks,1,'last');
%%
simt = 2e4; 
T = 1:1e-2:simt;
Amax = 500; 
S_test=(Amax/simt)*T;           
S_in=zeros(1,length(T));                % initialize the input spike train

for k=1:length(T)
    tst=rand(1)*Amax;
    if tst < S_test(k)*1e-2            % note arbitrary multiplyer to control spiking rate
        S_in(k)=1;                      % insert a 'random' input spike
    end
end
figure; plot(T,S_in)

%%
tbconv = S_in;
g_alpha = conv(tbconv, alpha_syn, 'same'); 
g_exp2 = conv(tbconv, exp2_syn, 'same'); 

figure;
subplot(211); hold on; 
plot(g_alpha); 
subplot(212);
plot(g_exp2);
%%
spks([1:first_spk,last_spk:end]) = '';
% S_in([1:first_spk,last_spk:end]) = '';
g_alpha_sin = conv(S_in, alpha_syn, 'same'); 
g_alpha_spk = conv(spks, alpha_syn, 'same'); 

figure;
subplot(211); hold on; 
plot(g_alpha_sin);


subplot(212); hold on; 
plot(g_alpha_spk);


