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
    case 'LATTICE'
        x = obj.coord.x;
        y = obj.coord.y;
        mrkscl = 1/2;
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