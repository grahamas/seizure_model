function ent = return_entropy(p)
p = p(:) / sum(p, 'all'); 
ent = -p.*log2(p);
ent = sum(ent(~isnan(ent) & ~isinf(ent)), 'all'); 
end
