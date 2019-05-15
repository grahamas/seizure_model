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
        normz_style = return_field_value(spatial_distribution, ...
            'norm', 'arc'); 
        
        obj.set_sphere_coordinates(normz_style);
        
    case 'LATTICE'
        [lat_def, ind_def] = lattice_4E1I_template;
        
        try 
            [lat_tmpl, ind_tmpl] = return_field_value(spatial_distribution, ...
                'lattice_template', lat_def, 'index_template', ind_def, '*strict*', 1);
        catch
            error(['Either both "lattice_template" and "index_templare" '...
                'or neither can be present']);
        end
        
        dist_majr = return_field_value(spatial_distribution, 'lattice_distance', 2);
            
        obj.set_lattice_coordinates(lat_tmpl, ind_tmpl, dist_majr);

    otherwise
        error(gen_err_type);
end
obj.coord.type = spatial_type;

end