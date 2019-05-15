clc; clear; close; 

addpath(genpath('functions')); 
FFW = [0,1,1;0,0,0;0,-1,0]; 
FB = [0,1,0;0,0,1;0,-1,0]; 

% Take a look at the pdf -> 106 
ID_FFW = EI3NodeMotif.weimat2ID(FFW);

% Take a look at the pdf -> 114
ID_FB = EI3NodeMotif.weimat2ID(FB);
%%
% Series of FFW
S_FFW  = [ ...
    0     1     0     0     1     0
    0     0     1     0     0     1
    0     0     0     0     0     0
    -1     0     0     0     0     0
    0    -1     0     0     0     0
    0     0    -1     0     0     0];
comb3node = nchoosek(1:6,3); 
ID_SFFW = zeros(size(comb3node,1),1); 
tic; 
for i = 1:size(comb3node,1)
    comb_i = comb3node(i,:); 
    g_i = S_FFW(comb_i, comb_i); 
    ID_SFFW(i) = EI3NodeMotif.weimat2ID(g_i); 
end

% Unique IDs (see the pdf) 
unq_ids = unique(ID_SFFW); 

% Corresponding counts 
cnts = arrayfun(@(x) sum(ID_SFFW == x), unq_ids, 'uni', 1);

% Subgraphs that have a specific ID
ID2look4 = 106; 
fprintf('All 3-node subgraphs that have ID = %d are \n', ID2look4); 
disp(comb3node(ID_SFFW == ID2look4,:))

toc; 