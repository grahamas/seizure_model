function v = bound_minmax(v, low_bound, upp_bound)
v = max(min(v, upp_bound), low_bound);
end
