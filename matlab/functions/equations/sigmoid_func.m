function res = sigmoid_func(x, x_half, k_x)
res = 1./(1+exp( (x_half - x)./k_x )); 
end