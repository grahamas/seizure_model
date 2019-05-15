function v = to_row_vec(v)
v = v(:);
if size(v, 1) > 1
    v = v';
end
end