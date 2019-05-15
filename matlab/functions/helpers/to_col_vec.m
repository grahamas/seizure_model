function v = to_col_vec(v)
v = v(:);
if size(v, 2) > 1
    v = v';
end
end