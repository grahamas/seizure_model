classdef bkupNetworkArchitecture < handle 
    properties 
        num_neurons  
        pop_ind
        coord
        centered_neuron
        dist
        syn_strength
        syn_conductance 
        colors 
    end 
    methods
        function obj = NetworkArchitecture( num_neurons, ...
                                            prob_e, ...
                                            spatial_distribution, ...
                                            weight_prm)           
            obj.set_population_indices(num_neurons, prob_e);
            obj.set_pseudo_coordinates(spatial_distribution); 
            obj.set_strength_matrices(weight_prm);   
            
            obj.colors.PE = [0,0.1,0.7]; 
            obj.colors.PI = [0.9,0,0];
        end 
        
        function set_population_indices(obj, num_neurons, prob_e)
            NE = ceil(prob_e*num_neurons);
            PE = 1:NE;
            PI = (NE+1):num_neurons;
            
            Pmarked = zeros(num_neurons); 
            Pmarked(PE) = +1; 
            Pmarked(PI) = -1; 
            
            obj.num_neurons = num_neurons;
            obj.pop_ind = struct('PE', PE, 'PI', PI, 'Pmarked', Pmarked);
        end
        
        function set_rect_coordinates(obj, rect_size) 
            
            % First obtain a grid
            N = obj.num_neurons; 
            lenX = rect_size(1);
            lenY = rect_size(2);
            
            xvec = 1:lenX;
            yvec = 1:lenY;
            
            combo_coord = return_combomat(xvec, yvec);
            
            % Shuffle the order 
            shuff_coord = combo_coord(randperm(N), :);
            
            x = shuff_coord(:,1);
            y = shuff_coord(:,2);
            
            % Euclidean distance 
            dist_mat = euclidean_distance_matrix(x, y); 
            
            % Get center coordinate 
            xcent = ceil(lenX/2);
            ycent = ceil(lenY/2);
            cent_ind = find(x == xcent & y == ycent);
            
            % Save to struct and fields 
            obj.coord = struct( 'x', x, 'y', y, ...
                                'size', rect_size);
            obj.dist = dist_mat;
            obj.centered_neuron = struct( 'x', xcent, 'y', ycent, ...
                                          'ind', cent_ind);
        end
        
        function set_sphere_coordinates(obj, normz_style)
            
            % Obtain x, y, z coordinate of a Fibonaci sphere 
            % with a certain normalization for the smallest dist = 1 
            N = obj.num_neurons; 
            [x, y, z] = fib_sphere(N, normz_style); 
            
            % Shuffle the order
            shuff_ind = randperm(N); 
            
            x = x(shuff_ind); 
            y = y(shuff_ind); 
            z = z(shuff_ind); 
            
            % Get distance matrix based on the `normz_style`
            dist_mat =  spherical_distance_matrix(x, y, z, normz_style);
            
            % Hemisphere indinces, +1 -> upper, -1 -> lower 
            hemi_ind = zeros(size(z));
            hemi_ind(z >= 0) = +1; % upp
            hemi_ind(z <  0) = -1; % low

            % Assume center is the highest point 
            [~, ind_zmax] = max(z);

            xcent = x(ind_zmax); 
            ycent = y(ind_zmax); 
           
            % Projection onto the plane z = min(z) 
            R_est = max(sqrt(x.^2 + y.^2 + z.^2), [], 'all');
            proj_x = R_est * x ./ (R_est + abs(z));
            proj_y = R_est * y ./ (R_est + abs(z));            
            
            % Keep them apart for plotting purposes
            horz_shift = 1.2*(max(proj_x(:)) - min(proj_x(:)));
            low_hemi = hemi_ind == -1;  
            proj_x(low_hemi) = proj_x(low_hemi) + horz_shift;

            % Center 
            proj_xcent = proj_x(ind_zmax); 
            proj_ycent = proj_y(ind_zmax);
                    
            % Save to struct and fields 
            obj.coord = struct( 'x', x, 'y', y, 'z', z, ...
                                'hemi_ind', hemi_ind, ...
                                'proj_x', proj_x, 'proj_y', proj_y); 
            obj.dist = dist_mat; 
            obj.centered_neuron = struct( 'x', xcent, 'y', ycent, ...
                                          'ind', ind_zmax, ...
                                          'proj_xcent', proj_xcent, ...
                                          'proj_ycent', proj_ycent); 
            
        end
        
        function set_pseudo_coordinates(obj, spatial_distribution)
            
            % Spatial distribution type 
            gen_err_type = ['`spatial_distribution` must have a `type` field' ...
                ' that could either be "rect" or "sphere"']; 
            
            try 
                spatial_type = upper(spatial_distribution.type);
            catch 
                error(gen_err_type);
            end
            
            % Specific parameters for each type 
            switch spatial_type
                case 'RECT' 
                    try 
                        rect_size = spatial_distribution.size; 
                    catch 
                        error('`spatial_distribution` must have a field `size` for "rect" style');
                    end
                        
                    obj.set_rect_coordinates(rect_size);
                    
                case 'SPHERE'
                    try 
                        normz_style = spatial_distribution.norm;
                    catch 
                        normz_style = 'sphere'; 
                    end 
                    
                    obj.set_sphere_coordinates(normz_style); 
                    
                otherwise 
                    error(gen_err_type);
            end
            obj.coord.type = spatial_type; 
                    
        end
              
        function set_strength_matrices(obj, weight_prm)
            % Obtain MU_S for different specific connections 
            try 
                sprm_E2E = weight_prm.EtoE; 
                sprm_E2I = weight_prm.EtoI; 
                sprm_I2E = weight_prm.ItoE; 
                sprm_I2I = weight_prm.ItoI;
            catch 
                error(['The `weight_prm` struct needs to have these fields: ' ...  
                    '`EtoE`, `EtoI`, `ItoE`, `ItoI`']);
            end
            
            mu_sE2E = obj.set_specific_strength(sprm_E2E);
            mu_sE2I = obj.set_specific_strength(sprm_E2I);
            mu_sI2E = obj.set_specific_strength(sprm_I2E);
            mu_sI2I = obj.set_specific_strength(sprm_I2I);            
            
            % Assign to general matrices SE and SI 
            PE = obj.pop_ind.PE; 
            PI = obj.pop_ind.PI; 
            
            SE = zeros(size(mu_sE2E));
            SI = zeros(size(mu_sE2E)); 
            
            % (TO, FROM)
            SE(PE, PE) = mu_sE2E(PE, PE);
            SE(PI, PE) = mu_sE2I(PI, PE);            
            
            SI(PE, PI) = mu_sI2E(PE, PI);
            SI(PI, PI) = mu_sI2I(PI, PI);
            
            obj.syn_strength = struct('SE', SE, 'SI', SI );
        end
        
        function neigh_ind = pick_random_neighbors(obj, num_neigh, start_ind)
            N = obj.num_neurons;
            
            if nargin < 2 || num_neigh < 1
                num_neigh = 1; 
            end
            if nargin < 3
                start_ind = randi(N); 
            else 
                if ischar(start_ind) 
                    switch upper(start_ind)
                        case 'RANDOM'
                            start_ind = randi(N); 
                        case 'CENTER'
                            start_ind = obj.centered_neuron.ind; 
                        otherwise 
                            error(['`start_ind` can only be numeric, or ' ...
                                'either of these strings: "random", "center"']); 
                    end
                end
            end
            
            dist2neighs = obj.dist(start_ind,:);  
            [~, sorted_neighs] = sort(dist2neighs, 'ascend');
            num2pickfrom = min([N - 1, num_neigh]); 
            neigh_ind = sorted_neighs(randperm(num2pickfrom, num_neigh) + 1); 
            
        end
        
        function mu_s = set_specific_strength(obj, prm_strct)
            % Necessary fields 
            try
                type_s = prm_strct.type;
            catch
                error(['The weight struct needs to have at least this field:' ...
                    ' `type`']);
            end
            
            % Default values of optional fields 
            k_s = return_field_value(prm_strct, 'k', inf); 
            m_s = return_field_value(prm_strct, 'm', 1);             
            bound_s = return_field_value(prm_strct, 'bound_weight', [0, 1]); 
            range_d = return_field_value(prm_strct, 'dist_range', [0, inf]); 
            def_s = return_field_value(prm_strct, 'def', 0);
            
            % Get mu_s
            mu_s = obj.return_mu_s(k_s, m_s, type_s, bound_s, range_d, def_s);    
        end
        
        function mu_s = return_mu_s(obj, k_s, m_s, type_s, ...
                                    bound_s, range_d, def_s)
            dist_mat = obj.dist; 
            
            % MU_S depends on the type of spatial kernel/dependence 
            if isinf(k_s) && ~strcmpi(type_s, 'RECT')
                error('Cannot have `type` = "RECT" if `k` = inf'); 
            end
            
            switch upper(type_s)
                case 'EXP'
                    mu_s = m_s * exp(-dist_mat / k_s); 
                case 'GAUSS' 
                    mu_s = m_s * exp(-dist_mat.^2 / k_s);
                case 'RECT'
                    mu_s = m_s * ones(size(dist_mat)); 
                otherwise 
                    error(['Type of spatial-related synaptic normalized' ...
                        ' strengths could only be "EXP" for exponential decay,' ...
                        ' "GAUSS" for a Gaussian-shaped decay, or' ...
                        ' "RECT" for a constant value.']);
            end
            
            % Bounded distance 
            if range_d(1) >= range_d(2)
                error(['Distance range needs to be a 2-element ' ...
                    'vector with increasing value']);
            end
            
            mu_s(dist_mat < range_d(1) | dist_mat > range_d(2)) = def_s;             
            
            % Hard-bounded weight (strength) 
            if bound_s(1) >= bound_s(2)
                error(['Weight bound needs to be a 2-element ' ...
                    'vector with increasing value']); 
            end 
            
            zero_self = 1 - eye(obj.num_neurons);  
            mu_s(isinf(mu_s) | isnan(mu_s)) = 0; 
            mu_s = bound_minmax(mu_s, bound_s(1), bound_s(2)) .* zero_self;
        end
        
        function [GE, GI] = set_synaptic_conductances(obj, G, scale_style)
            scale_by = obj.return_synaptic_scale(scale_style);
            
            try 
                E2E = G.EtoE; 
                E2I = G.EtoI;
                I2E = G.ItoE;
                I2I = G.ItoI; 
            catch 
                error(['`G` has to have these fields: ' ...
                    '`EtoE`, `EtoI`, `ItoE`, `ItoI`']);
            end
            
            PE = obj.pop_ind.PE; 
            PI = obj.pop_ind.PI; 
            
            SE = scale_by * obj.syn_strength.SE; 
            SI = scale_by * obj.syn_strength.SI; 
            
            GE = zeros(size(SE)); 
            GI = zeros(size(SI)); 
            
            % (TO, FROM)
            GE(PE, PE) = E2E * SE(PE, PE);
            GE(PI, PE) = E2I * SE(PI, PE);            
            
            GI(PE, PI) = I2E * SI(PE, PI);
            GI(PI, PI) = I2I * SI(PI, PI);
            
            obj.syn_conductance = struct('GE', GE, 'GI', GI);
        end
        
        function res = return_synaptic_scale(obj, scale_style)
            N = obj.num_neurons; 
            switch upper(scale_style)
                case 'UNITY'
                    res = 1;
                case 'LINEAR' 
                    res = 1/N; 
                case 'SQRT'
                    res = 1/sqrt(N);
                otherwise 
                    error(['The synaptic conductance scale type can only' ...
                        ' be either of these: "UNITY", "LINEAR" or "SQRT"']);
            end            
        end
        
        function [x,y,mrkscl,gobj4lgdn] = visualize_population(obj, pop_prop, further_marked_ind)
            
            if nargin < 2 || isempty(pop_prop) 
                pop_nmes = {'EXC neuron','INH neuron'};
                pop_clrs = {obj.colors.PE, obj.colors.PI};
            else
                pop_nmes = pop_prop.names;
                pop_clrs = pop_prop.colors;
            end
            
            if nargin < 3
                further_marked_ind = [];
            end
            
            PE = obj.pop_ind.PE; 
            PI = obj.pop_ind.PI; 
            
            spatial_type = obj.coord.type;
            switch spatial_type 
                case 'RECT'                    
                    x = obj.coord.x;
                    y = obj.coord.y;
                    mrkscl = 1; 
                case 'SPHERE'
                    x = obj.coord.proj_x; 
                    y = obj.coord.proj_y; 
                    mrkscl = 1/4; 
            end 
            
            figure; hold on; 
            gobj4lgdn = gobjects(1,3); 
            gobj4lgdn(1:2) = cellfun(@(pop,clr,nme) ...
                scatter(x(pop), y(pop), ...
                150*mrkscl, clr, 'filled', 'o', 'DisplayName', nme), ...
                {PE, PI}, pop_clrs, pop_nmes);
             
            if ~isempty(further_marked_ind)
                gobj4lgdn(3,3) = scatter(x(further_marked_ind), y(further_marked_ind), ...
                    300*mrkscl, 'k', 'o', 'DisplayName', 'Further marked');
            end
            
            gobj4lgdn = gobj4lgdn(isgraphics(gobj4lgdn));
            legend(gobj4lgdn, 'Location', 'southoutside');
           	daspect([1,1,1]); 
                    
            
        end
        
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
        
        function create_activity_movie(obj, vid_name, t_res, resp, t_in, inp, further_marked)    
            
            % Set positions of axes and location of legend
            switch obj.coord.type
                case 'RECT'
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
            res_amp = ceil((resp - res_rng(1))/abs(diff(res_rng)));
            res_lvl = (num_lvl - 1) * res_amp + 1; 
            
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
    end

end 