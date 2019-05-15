clc; clear; 
dt = 0.001; 
tmax = 20; 
Imax = 1; 
n_src = 10; 
r_dcy = 0.1; 

T = 0:dt:tmax; 
lenT = length(T); 

tmp_rdcy = zeros(n_src, n_src); 
for i = 1:n_src
    tmp_rdcy(i,i:end) = 1:(n_src-i+1);
end
tmp_rdcy = tmp_rdcy+triu(tmp_rdcy,1)'-1;
rdcy_mat = r_dcy.^tmp_rdcy - eye(n_src);

tmp_ramp_decay = zeros(1, lenT); 
dur_ramp = ceil(2*lenT/5);
tmp_ramp_decay(1:dur_ramp) = linspace(0,1,dur_ramp); 
tmp_ramp_decay(dur_ramp+1:end) = exp(-(0:(lenT-dur_ramp-1))/(T(end))); 

I_ramp = Imax*tmp_ramp_decay; 

I_inp = zeros(n_src, lenT);
t = 0; 
k = 1; 

inp = I_inp(:,1); 
inp(1) = tmp_ramp_decay(1); 

while t < tmax 
    I_inp(:,k) = inp; 
    dinp = rdcy_mat * inp - inp; 
    dinp(1) = dinp(1) + tmp_ramp_decay(k);
    
    dinp = dt*dinp; 
    inp = inp + dinp; 
    t = t + dt; 
    k = k + 1;
end

%% 
[peak_amps,time_peak] = max(I_inp,[],2); 
cmap = summer(n_src)*0.9; 
figure; 
subplot(211); hold on; 
arrayfun(@(x) plot(T,I_inp(x,:)/peak_amps(x),'linewidth',1,'color',cmap(x,:)), 1:n_src);
colorbar; caxis([1,n_src]); colormap(cmap);

subplot(212); hold on; 
plot(1:n_src, peak_amps, '-kd'); 
set(gca, 'yscale', 'log'); 
yyaxis right 
plot(2:n_src, peak_amps(2:end)./peak_amps(1:end-1), '-ob'); 
