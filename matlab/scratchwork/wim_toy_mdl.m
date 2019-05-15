% test12
% LeakNaPandK_Model (Izhikevich, 2007)
%  High threshold K: N_vhalf=-25, El=-80
%  Low threshold K: N_vhalf=-45, El=-78
% A is the area in relative units: for I cell == 1 and E cell ==9

% NOTE SEE ALSO pr23_6 for the underlying dynamics!!!
% e.g.  pr23_6(0, -45, -78);   Fig. 23.8 Supercritical Hopf
%       pr23_6(0, -25, -80);   Fig. 23.7 Saddle node on invariant cycle
%       pr23_6(100, -45, -78); Fig. 23.8 Supercritical Hopf
%       pr23_6(150, -25, -80); Fig. 23.7 Saddle node on invariant cycle

% exponential coeff
%ampar=1/(3*10^-3);            % AMPA rise time
%ampad=1/(10*10^-3);           % AMPA decay time
%gabar=1/(10*10^-3);           % GABA rise time
%gabad=1/(60*10^-3);           % GABA decay time
%nmdar=1/(50*10^-3);           % NMDA rise time
%nmdad=1/(150*10^-3);          % NMDA decay time  %%%%%%% CHANGED from 600

clear;
% close all;
tic
% MAKE SOME CHOICES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

feedforward=2;                          % pick feedforward (1);
% feedback is (0) or both (2)
delay_AMPA=2000;                        % conduction delay in micros
delay_GABA=5000;
ramp=1;                                 % input wave is a ramp (1) or a
% bump (0)
% Synaptic Input from the ictal wave
Amax=570;
%Amax=800;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;                                 % reserve figure

%constants
C=1;
gl=8;
Ena=60;
gna=20;
M_vhalf=-20;
M_k=15;
Ek=-90;
gk=10;
N_k=5;
tau=1;                                  % Note that tau isn't V dependent

% HP filter for the detector
MP1f(1)=0;
MP2f(1)=0;
F=.2;
tauF=1/(2*pi*F);

% synaptic parms #1 - exc, #2 - inh
alpha1=25;
beta1=.3;
alpha2=-3;
beta2=0.1;

% simulation parameters
simt=5000;                               % epoch length
dt=1/1000;                              % time step for numerical solution
T=0:dt:simt;

if ramp==1
    S_test=(Amax/simt)*T;                   % ramp @ input
else
    S_test=exp(-((T-simt/2)/(simt/3)).^2);  % bump @ input
    S_test=(S_test-S_test(1))*Amax;
end

%S_test=510*ones(1,length(T));
S_in=zeros(1,length(T));                % initialize the input spike train

for k=1:length(T)
    tst=rand(1)*Amax;
    if tst < S_test(k)*0.7             % note arbitrary multiplyer to control spiking rate
        S_in(k)=1;                      % insert a 'random' input spike
    end
end

% compute the EPSPs for the input
% initialize sim (define z=dy/dt and rewrite the 2nd order ODE)
z(1)=0;
y(1)=0;

for k=1:length(T)-1
    dy=z(k);
    y(k+1)=y(k)+dy*dt;
    dz=alpha1*beta1*S_in(k)-2*beta1*z(k)-y(k)*beta1^2;
    z(k+1)=z(k)+dz*dt;
end

I_inj=y*(Amax/max(y));                % set the input inject to scale * EPSP signal

% parameters that vary per cell type
% PYRAMIDAL E-CELL
v1=-60;                                  % initial value for Vm
N_vhalf1=-25;
El1=-80;
A1=9;

I_inj1=I_inj/A1;                         % correct for area A1

%PARVALBUMIN I-CELL
v2=-60;                                 % initial value for Vm
N_vhalf2=-45;
El2=-78;
% El2=-80 % !! gives a herald spike

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
A2=1;
I_inj2=I_inj/A2;                        % correct for area A

flagD1=0;
flagD2=0;

% Time Series
% -----------
n1=1/(1+exp((N_vhalf1-v1)/N_k));     % Initialize n1
n2=1/(1+exp((N_vhalf2-v2)/N_k));     % Initialize n2
% initialize synaptic parms
z1(1)=0;
y1(1)=0;
z2(1)=0;
y2(1)=0;
% Initialize spike detector
clear D1;                            % make sure detections are cleared
clear D2;
x1=zeros(1,length(T));               % initialize synaptic signal
x2=zeros(1,length(T));              % initialize synaptic signal 2
threshold=20;                       % detection threshold
k_prev1=-1500;
k_prev2=-1500;

% SIMULATION LOOP
t=0;
k=1;
p=1;
while (t<simt)
    %%%%%%%%%%%%%%%%%%%%% Neuron 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MP1(k)=v1;   % Store last Membrane Potential in the Array
    
    % ARMA filter based on RC circuit
    if (k>1)
        dMP1f=(MP1(k)-MP1(k-1))-MP1f(k-1)*dt/tauF;          % high pass filter
        MP1f(k)=MP1f(k-1)+dMP1f;                           % for spike detection purpose
    end
    
    % Detect of a spike occurred in filtered signal
    if (k>2) & (MP1f(k-1)>threshold)                  % first check if the level is worthwhile analyzing
        if((MP1f(k-1)>=MP1f(k-2))&(MP1f(k-1)>=MP1f(k))& ...
                ((k+delay_AMPA)< length(x1)))            % is the point a relative maximum (Note the >= sign)?
            if (k-k_prev1 > 1500)                        % if yes, is it not a subsequent maximum in the same signal
                D1(p)=k;                                 % !! YES detected spike !!
                x1(k+delay_AMPA)=x1(k+delay_AMPA)+1/dt;
                k_prev1=k;
                p=p+1;
                flagD1=1;
            end
        end
    end
    
    % Compute synaptic output for AMPA
    dy1=z1(k);
    y1(k+1)=y1(k)+dy1*dt;
    dz1=alpha1*beta1*x1(k)-2*beta1*z1(k)-y1(k)*beta1^2;
    z1(k+1)=z1(k)+dz1*dt;
    m_inf=1/(1+exp((M_vhalf-v1)/M_k));   % m is instantaneous
    n_inf=1/(1+exp((N_vhalf1-v1)/N_k));   % the new equilibrium for n
    dn=dt*(n_inf-n1)/tau;
    n1=n1+dn;                             % update n1
    current=I_inj1(k)+y2(k);             % exc & inhibition (y2)
    dv=(dt/C)*(current-gl*(v1-El1)-gna*m_inf*(v1-Ena)-gk*n1*(v1-Ek));
    
    % The new membrane potential of the pyramidal cell
    v1=v1+dv;
    
    %%%%%%%%%%%%%%%%%%%%% Neuron 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MP2(k)=v2;   % Store last Membrane Potential in the Array
    
    % ARMA filter based on RC circuit
    if (k>1)
        dMP2f=(MP2(k)-MP2(k-1))-MP2f(k-1)*dt/tauF;       % high pass filter
        MP2f(k)=MP2f(k-1)+dMP2f;                         % for spike detection purpose
    end
    
    % Detect of a spike occurred in filtered signal
    if (k>2) & (MP2f(k-1)>threshold)                    % first check if the level is worthwhile analyzing
        if((MP2f(k-1)>=MP2f(k-2))&(MP2f(k-1)>=MP2f(k))& ...
                ((k+delay_GABA)<length(x2)))            % is the point a relative maximum (Note the >= sign)?
            if (k-k_prev2 > 1500)                        % if yes, is it not a subsequent maximum in the same signal
                D2(p)=k;                                 % !! YES detected spike !!
                x2(k+delay_GABA)=x2(k+delay_GABA)+1/dt;
                k_prev2=k;
                p=p+1;
                flagD2=1;
            end
        end
    end
    
    % Compute synaptic output for GABA-A
    dy2=z2(k);
    y2(k+1)=y2(k)+dy2*dt;
    dz2=alpha2*beta2*x2(k)-2*beta2*z2(k)-y2(k)*beta2^2;
    z2(k+1)=z2(k)+dz2*dt;
    
    m_inf=1/(1+exp((M_vhalf-v2)/M_k));      % m is instantaneous
    n_inf=1/(1+exp((N_vhalf2-v2)/N_k));     % the new equilibrium for n
    dn=dt*(n_inf-n2)/tau;
    n2=n2+dn;                               % update n2
    
    %%%%%%%%% PICK INHIBITORY FEED FORWARD OR FEEDBACK
    if feedforward==0
        current2=y1(k)*20;
        msg=['feedback'];                   % exc from PYR = feedback
    end
    
    if feedforward==1
        current2=I_inj2(k);
        msg=['feedforward'];                % exc from feedforward
    end
    
    if feedforward==2
        current2=I_inj2(k)+y1(k)*20;
        msg=['feedforward and feedback'];  % exc from feedback&forward
    end
    
    dv=(dt/C)*(current2-gl*(v2-El2)-gna*m_inf*(v2-Ena)-gk*n2*(v2-Ek));
    
    % The new membrane potential of the parvalbumine cell
    v2=v2+dv;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% End NEURON 2
    
    % Update t & k
    t=t+dt;
    k=k+1;
end

% butterworth high pass filtered signal - for visual purposes only!!
fN=(1/dt)/2;
[a,b]=butter(2,.1/fN,'high');       % 2nd order higpass
MPfb1=filtfilt(a,b,MP1-mean(MP1));     % filtfilt to prevent phase-shift
MPfb2=filtfilt(a,b,MP2-mean(MP2));

toc
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Results
ax(1) = subplot(411);
plot(T(1:length(MP1)),I_inj(1:length(MP1)),'r')
ylabel('Synaptic Current (pA)')

ax(2) = subplot(412);
plot(T(1:length(MP1)),MP1,'k')
hold on
subplot(412),plot(T(1:length(MP1)),y1(1:length(MP1)),'r')
ylabel('Amplitude E (mV)')

if flagD1==1
    H=ones(length(D1),1)*max(MP1);
    plot(D1*dt,H,'.');
end

ax(3) = subplot(413);

plot(T(1:length(MP2)),MP2,'g')
hold on
subplot(413),plot(T(1:length(MP2)),y2(1:length(MP2)),'b')
ylabel('Amplitude I (mV)')

if flagD2==1
    H2=ones(length(D2),1)*max(MP2);
    plot(D2*dt,H2,'.');
end

% Pseudo EEG
[aa,bb]=butter(2,[.000001 .001]);       % 2nd order bandpass
pEEG=filter(aa,bb,y+y1+y2);
pEEG=-pEEG;                             % extracellular - inverted

ax(4) = subplot(414);
plot(T(1:length(MP2)),pEEG(1:length(MP2)),'k')
ylabel('Pseudo-EEG Amplitude (AU)')
xlabel('Time (ms)')

subplot(411);title(msg)
linkaxes(ax,'x');