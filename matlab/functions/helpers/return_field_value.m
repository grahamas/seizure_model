function varargout = return_field_value(struct_obj, varargin)

if mod(length(varargin),2) ~= 0 || length(varargin) < 2
    error('The inputs need to come in pairs ("field_name", "default_value")');
end

all_fields = varargin(1:2:end-1);
all_defvals = varargin(2:2:end);

strict_allfields = 0; 
find_strict = find(strcmpi(varargin, '*strict*')); 
if ~isempty(find_strict)
    if find_strict ~= length(varargin) - 1
        error(['The function parameter "*strict*" can only appear at the end' ...
            ' with the value of whether to be strict about returning' ...
            ' field values or default values of the struct object']);
    end
    strict_allfields = varargin{end}; 
    
    all_fields = all_fields(1:end-1); 
    all_defvals = all_defvals(1:end-1); 
end

if nargout ~= length(all_fields)
    error('The number of output needs to agree with number of input fields'); 
end
 
check_field_exist = isfield(struct_obj, all_fields); 
if strict_allfields && ...
        ~(all(check_field_exist) || all(~check_field_exist))
    error(['The input indicated a strict requirement to have all or none' ...
        ' the fields, but the struct has only some of the fields.' ...
        ' Please consider relaxing the requirement if not desired.']); 
end

varargout = cell(nargout, 1); 
for i = 1:nargout
    out_i = all_defvals{i}; 
    if isfield(struct_obj, all_fields{i})
        out_i = struct_obj.(all_fields{i});
    end
    varargout{i} = out_i; 
end

end