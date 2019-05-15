function visualize_connection_matrices(obj, varargin)
switch nargin
    case 1
        mat_type = 'S';
    case 2
        mat_type = varargin{1};
    case 3
        mat_type = 'U';
    otherwise
        error('There can only be at most 2 additional inputs');
end

switch upper(mat_type)
    case 'G'
        CONN_E = obj.syn_conductance.GE;
        CONN_I = obj.syn_conductance.GI;
        ttl_suf = 'conductance';
    case 'S'
        CONN_E = obj.syn_strength.SE;
        CONN_I = obj.syn_strength.SI;
        ttl_suf = 'strength (or weight)';
    case 'U'
        CONN_E = varargin{1};
        CONN_I = varargin{2};
        ttl_suf = 'connection (user input)';
    otherwise
        error('The input could only be either "G" or "S"');
end

lim_pseudo = [1, obj.num_neurons] + 0.5*[-1,1];
flip_gray = flipud(gray(1000));

figure;
colormap(flip_gray);
subplot(121); hold on;
image(CONN_E, 'CDataMapping', 'scaled');
set(gca, 'ydir', 'reverse', 'box', 'on', 'linewidth', 2);
axis square; xlim(lim_pseudo); ylim(lim_pseudo);
xlabel('From'); ylabel('To');
title(['Excitatory ' ttl_suf], 'FontWeight', 'normal');
colorbar('box', 'off');

subplot(122); hold on;
image(CONN_I, 'CDataMapping', 'scaled');
set(gca, 'ydir', 'reverse', 'box', 'on', 'linewidth', 2);
axis square; xlim(lim_pseudo); ylim(lim_pseudo);
xlabel('From'); ylabel('To');
title(['Inhibitory ' ttl_suf], 'FontWeight', 'normal');
colorbar('box', 'off')
end