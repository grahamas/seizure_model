function mi = mutual_information(X, Y, bin_size)
X = X(:); Y = Y(:); 
[~, edge_X] = bin_edges_and_centers(X,bin_size);
[~, edge_Y] = bin_edges_and_centers(X,bin_size);

entX = return_entropy(histcounts(X, edge_X, 'Normalization', 'probability')); 
entY = return_entropy(histcounts(Y, edge_Y, 'Normalization', 'probability')); 
entXY = return_entropy(histcounts2(X, Y, edge_X, edge_Y, 'Normalization', 'probability'));

mi = entX + entY - entXY; 
end


