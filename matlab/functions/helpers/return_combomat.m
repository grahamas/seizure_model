function combo_mat = return_combomat(varargin)
tmp_cell = cell(nargin,1);
[tmp_cell{:}] = ndgrid(varargin{:}); 
tmp_cell = cellfun(@(x) x(:), tmp_cell, 'uni', 0);
combo_mat = horzcat(tmp_cell{:}); 
end