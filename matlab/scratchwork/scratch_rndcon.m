clc; clear; %close all; 
addpath(genpath('functions'))
N = 16; 
prob_e = 0.7; 
prob_i = 1 - prob_e;
lenX = 4; 
lenY = 4; 
sz_2d = [lenX,lenY]; 

Ne = ceil(prob_e*N); 
Ni = N - Ne;

% Pe = randsample(N,Ne); 
% Pi = setdiff(1:N,Pe);
Pe = 1:Ne; 
Pi = (Ne+1):N;

xvec = 1:lenX; 
yvec = 1:lenY; 
combo_coord = return_combomat(xvec, yvec);
shuff_coord = combo_coord(randperm(N),:); 
x_coord = shuff_coord(:,1);
y_coord = shuff_coord(:,2);

figure; hold on; 
cellfun(@(pop,clr,nme) scatter(x_coord(pop), y_coord(pop), 100, clr, 'filled', ...
    'o', 'DisplayName', nme), {Pe,Pi}, {[0,0.1,0.7],[0.9,0,0]}, {'PYR','PV'}); 
axis square

%%
Rmat = bsxfun(@(i,j) sqrt( ...
            (x_coord(i) - x_coord(j)).^2 + ...
            (y_coord(i) - y_coord(j)).^2), 1:N, (1:N)');

k_se = 16;
m_se = 1; 
k_si = 48; 
m_si = 1; 

mu_se = m_se*exp(-Rmat.^2/k_se);
mu_si = m_si*exp(-Rmat.^2/k_si); 

bound_s = @(x) max(min(1,x),0);
zero_self = 1 - eye(N,N);
se = bound_s(mu_se).*zero_self; 
si = bound_s(mu_si).*zero_self; 

%%
rnd_pnt = randi(N); 
conn2pnt = se(rnd_pnt,:); 
idx2pnt = find(conn2pnt > 0);

x_coordjit = x_coord + 0*randn(size(x_coord));
y_coordjit = y_coord + 0*randn(size(y_coord));
figure; hold on; 
cellfun(@(pop,clr,nme) scatter3(x_coordjit(pop), y_coordjit(pop), zeros(length(pop),1), ...
   50, clr, 'filled', 'o', 'DisplayName', nme), {Pe,Pi}, {[0,0.1,0.7],[0.9,0,0]}, {'PYR','PV'}); 
axis square  
arrayfun(@(x) plot3(x_coordjit([rnd_pnt,idx2pnt(x)]),...
    y_coordjit([rnd_pnt,idx2pnt(x)]),[1,0], ...
    'color', ones(1,3) - conn2pnt(idx2pnt(x)),...
    'linewidth', 2*conn2pnt(idx2pnt(x))+0.001), ...
    1:length(idx2pnt));
%%
R = 0:1:30; 
k_g = 16;
mu_g = exp(-R/k_g); 
figure; plot(R, mu_g);

%%
R = 0:.1:100; 
k_se = 4;
m_se = 1.5; 
k_si = 10; 
m_si = 1; 

mu_se = m_se*exp(-R/k_se);
mu_si = m_si*exp(-R/k_si); 

figure; 
subplot(121); hold on; 
plot(R, mu_se, '-b', 'linewidth', 2);
plot(R, mu_si, '-r', 'linewidth', 2); 
plot(R, mu_se - mu_si, '-k', 'linewidth', 2);
plot(R([1,end]), [0,0], ':k');
legend('EXC', 'INH', 'EXC - INH'); 
ylim([-0.4, 1.6]); 
xlabel('Pixel'); 

k_se = 16;
m_se = 1.5; 
k_si = 48; 
m_si = 1; 

mu_se = m_se*exp(-R.^2/k_se) + 0.1*m_se*exp(-(R-30).^2/k_se) + 0.01*m_se*exp(-(R-60).^2/k_se);
mu_si = m_si*exp(-R.^2/k_si); 

subplot(122); hold on; 
plot(R, mu_se, '-b', 'linewidth', 2);
plot(R, mu_si, '-r', 'linewidth', 2); 
plot(R, mu_se - mu_si, '-k', 'linewidth', 2);
legend('EXC', 'INH', 'EXC - INH'); 

plot(R([1,end]), [0,0], ':k');
%%
R = 0:0.1:30; 
var_se = 5;
var_si = 10; 
SpatialDim = 1; 
p_se = (1/sqrt(2*pi*var_se))^SpatialDim*exp(-R.^2/(2*var_se));
p_si = (1/sqrt(2*pi*var_si))^SpatialDim*exp(-R.^2/(2*var_si));

figure; hold on;
plot(R, p_se, 'b');
plot(R, p_si, 'r');
plot(R, p_se - p_si, 'k');

%%
Rsq = bsxfun(@(i,j) (x_coord(i) - x_coord(j)).^2 + ...
                    (y_coord(i) - y_coord(j)).^2, 1:N, (1:N)'); 
var_conn = 100;  
p_conn = (1/sqrt(2*pi*var_conn))^SpatialDim*exp(-Rsq/(2*var_conn));
conn_mat = p_conn;
figure; histogram(conn_mat(conn_mat~=0),100,'Normalization','probability');
mean(arrayfun(@(x) sum(conn_mat(x,:) ~= 0)/N, 1:N, 'uni', 1))

%%
P_conn = 0.15;
n_conn = P_conn*N*(N-1);

bin_mat = zeros(N,N); 
idx_combo = return_combomat(1:N,1:N);
nonidentity = find(idx_combo(:,1) ~= idx_combo(:,2));
connected = randperm(length(nonidentity), n_conn); 
bin_mat(nonidentity(connected)) = 1;

% figure; 
% image(bin_mat,'cdatamapping','scaled'); 
% set(gca,'ydir','normal'); axis square; colormap('gray')
% 

Rmat = bsxfun(@(i,j) sqrt( ...
            (x_coord(i) - x_coord(j)).^2 + ...
            (y_coord(i) - y_coord(j)).^2), 1:N, (1:N)');
% Rmat = Rmat/max(Rmat(:)); 

k_gnormz = 5; 
mu_gnormz = exp(-Rmat/k_gnormz); 
sigma_gnormz = 5e-2;
bound_gnormz = @(x) max(min(1,x),0);
gnormz = bound_gnormz(normrnd(mu_gnormz,sigma_gnormz)); 
% gnormz = bin_mat .* gnormz;
gnormz(gnormz < quantile(gnormz(:),1-P_conn)) = 0;
figure; histogram(gnormz(gnormz~=0),100,'Normalization','probability');
mean(arrayfun(@(x) sum(gnormz(x,:) ~= 0)/N, 1:N, 'uni', 1))


rnd_pnt = randi(N); 
conn2pnt = gnormz(rnd_pnt,:); 
idx2pnt = find(conn2pnt > 0e-1);

cmap = flipud(hot(length(idx2pnt))*0.9); 
x_coordjit = x_coord + 0*randn(size(x_coord));
y_coordjit = y_coord + 0*randn(size(y_coord));
figure; hold on; 
cellfun(@(pop,clr,nme) scatter3(x_coordjit(pop), y_coordjit(pop), zeros(length(pop),1), ...
    10, clr, 'filled', ...
    'o', 'DisplayName', nme), {Pe,Pi}, {[0,0.1,0.7],[0.9,0,0]}, {'PYR','PV'}); 
% axis square  
arrayfun(@(x) plot3(x_coordjit([rnd_pnt,idx2pnt(x)]),...
    y_coordjit([rnd_pnt,idx2pnt(x)]),[1,0], ...
    'color', ones(1,3)*0.4, 'linewidth', 10*conn2pnt(x)+0.001), 1:length(idx2pnt));
%%
figure; hold on;
rnd_pnt = randi(N); 
plot(x_coord(rnd_pnt),y_coord(rnd_pnt), 'ko','linewidth',1.5,'markersize',30);
cellfun(@(pop,clr,nme) scatter(x_coord(pop), y_coord(pop), ...
    20*(1.01 + 4*gnormz(rnd_pnt,pop)), clr, 'filled', ...
    'o', 'DisplayName', nme), ...
    {Pe,Pi}, {[0,0.1,0.7],[0.9,0,0]}, {'PYR','PV'}); 
axis square
%% 
mu_gs = [0.01,0.05,0.1:0.1:0.9,0.95,0.99];
var_gs = 1e-3; 
alpha_distr = abs(( (1-mu_gs)/var_gs - 1./mu_gs).*mu_gs.^2); 
beta_distr = alpha_distr.*(1./mu_gs - 1);
% figure; plot(mu_gs, alpha_distr, '-k', mu_gs, beta_distr, '-r');

n_samples = 5e3; 
vec_mu = 1:length(mu_gs); 
x_gs = 0.001:0.001:1; 
cmap = parula(length(mu_gs))*0.8; 
figure; 
subplot(211); hold on; 
arrayfun(@(x,a,b) plot(x_gs,betapdf(x_gs,a,b), 'color', cmap(x,:)),...
     vec_mu,alpha_distr, beta_distr)
subplot(212); hold on; 
arrayfun(@(x,a,b) scatter(betarnd(a,b,1,n_samples), x*ones(1,n_samples), 30, cmap(x,:), ...
    'filled', 'o', 'markerfacealpha', 0.1), vec_mu,alpha_distr, beta_distr);

%%
mu_gs = [0.001,0.01,0.05,0.1:0.1:0.9,0.95,0.99,0.999];
sig_gs = 0.05;
bound_gs = @(x) max(min(1,x),0);
n_samples = 5e3; 
vec_mu = 1:length(mu_gs); 
x_gs = 0.001:0.001:1; 
cmap = parula(length(mu_gs))*0.8; 

figure; subplot(212)
hold on; 
arrayfun(@(x) scatter(bound_gs(normrnd(mu_gs(x),sig_gs,1,n_samples)), x*ones(1,n_samples), ...
    30, cmap(x,:), 'filled', 'o', 'markerfacealpha', 0.1), vec_mu);

