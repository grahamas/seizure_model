classdef NetworkArchitecture < handle 
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
        
        set_population_indices(obj, num_neurons, prob_e)
        
        set_rect_coordinates(obj, rect_size) 
            
        set_sphere_coordinates(obj, normz_style)
            
        set_lattice_coordinates(obj, lat_tmpl, ind_tmpl, dist_majr)
        
        set_pseudo_coordinates(obj, spatial_distribution)
            
        set_strength_matrices(obj, weight_prm)
                 
        neigh_ind = pick_random_neighbors(obj, num_neigh, start_ind)
          
        mu_s = set_specific_strength(obj, prm_strct)
        
        mu_s = return_mu_s(obj, k_s, m_s, type_s, ...
            bound_s, range_d, def_s)
        
        [GE, GI] = set_synaptic_conductances(obj, G, scale_style)
           
        res = return_synaptic_scale(obj, scale_style)
          
        [x,y,mrkscl,gobj4lgdn] = visualize_population(obj, pop_prop, further_marked_ind)

        visualize_connection_matrices(obj, varargin)

        create_activity_movie(obj, vid_name, t_res, resp, t_in, inp, further_marked)
            
    end

end 