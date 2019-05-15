function create_activity_movie(obj, vid_name, t_res, resp, t_in, inp, further_marked)

% Set positions of axes and location of legend
switch obj.coord.type
    case {'RECT', 'LATTICE'}
        pos_ax1 = [0.05, 0.15, 0.5, 0.75];
        loc_ax1_lgnd = 'southoutside';
        
        pos_ax2 = [0.6, 0.65, 0.35, 0.25];
        pos_ax3 = [0.6, 0.35, 0.35, 0.25];
        pos_ax4 = [0.6, 0.05, 0.35, 0.25];
    case 'SPHERE'
        pos_ax1 = [0.1, 0.25, 0.8, 0.7];
        loc_ax1_lgnd = 'best';
        
        pos_ax2 = [0.05, 0.02, 0.25, 0.2];
        pos_ax3 = [0.35, 0.02, 0.25, 0.2];
        pos_ax4 = [0.65, 0.02, 0.25, 0.2];
end

% Create video writer
vid_write = VideoWriter(sprintf('%s.avi', vid_name));
open(vid_write);

% Title style
ttl_style = {'FontSize', 12, 'FontWeight', 'normal'};

% First frame
% Draw the population and the stimulated neurons
[x, y, mrkscl, gobj4lgdn] = obj.visualize_population('', further_marked);
gobj4lgdn(3).DisplayName = 'Received external input';

set(gcf, 'units', 'normalized', 'position', [0,0,1,1], 'color', 'w');
ax1 = gca; hold(ax1, 'on');
set(ax1, 'xcolor', 'none', 'ycolor', 'none', 'position', pos_ax1);
legend(ax1, gobj4lgdn, 'Location', loc_ax1_lgnd);

% Axes for plotting time series
general_style = {'unit', 'normalized', 'visible', 'off'};
ax2 = axes(general_style{:}, 'position', pos_ax2);
ax3 = axes(general_style{:}, 'position', pos_ax3);
ax4 = axes(general_style{:}, 'position', pos_ax4);
arrayfun(@(ax) hold(ax, 'on'), [ax1, ax2, ax3, ax4]);

% Plotting input time series
inp = normalize_minmax(inp(further_marked, :));
plot(ax2, t_in, inp, '-k', 'LineWidth', 1);

% Plotting EXC time series
resp_E = normalize_minmax(resp(obj.pop_ind.PE,:));
plot(ax3, t_res, resp_E, 'LineWidth', 1, 'Color', obj.colors.PE);

% Plotting INH time series
resp_I = normalize_minmax(resp(obj.pop_ind.PI,:));
plot(ax4, t_res, resp_I, 'LineWidth', 1, 'Color', obj.colors.PI);

% Overlay with no activity for 1st frame
sc_handle = scatter(ax1, x, y, 70*mrkscl, 'w', 'filled', 'o');
title(ax1, 't = 0 s', ttl_style{:});

% Vertical line representing time
time_lines = arrayfun(@(ax) plot(ax, [0,0], [0,1], ':k', ...
    'LineWidth', 0.7), [ax2, ax3, ax4]);

% Save to video
vid_frame = getframe(gcf);
writeVideo(vid_write, vid_frame);

% Discretize amplitude levels into discrete colors
num_lvl = 100;
cmap = flipud(gray(num_lvl));

res_rng = [min(resp, [], 'all'), max(resp, [], 'all')];
res_amp = (resp - res_rng(1))/abs(diff(res_rng));
res_lvl = round((num_lvl - 1) * res_amp) + 1;

% Plot and write frame for each time point
for i = 1:length(t_res)
    ti = t_res(i);
    ri = res_lvl(:,i);
    
    % Overlay with the current amplitude
    delete(sc_handle);
    sc_handle = scatter(ax1, x, y, 70*mrkscl, cmap(ri,:), 'o', 'filled');
    title(ax1, sprintf('t = %.2f s', ti), ttl_style{:});
    legend(ax1, gobj4lgdn, 'Location', loc_ax1_lgnd);
    
    % Move vertical time line
    delete(time_lines);
    time_lines = arrayfun(@(ax) plot(ax, ti*[1,1], [0,1], ':k', ...
        'LineWidth', 0.7), [ax2, ax3, ax4]);
    
    % Save to video
    vid_frame = getframe(gcf);
    writeVideo(vid_write, vid_frame);
end

close(vid_write);
end