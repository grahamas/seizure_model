clear; close all;
%% Two simple motifs
FFW = [0 0 0; 1 0 -1; 1 0 0]; %feedforward motif
FB = [0 0 0; 1 0 -1; 0 1 0]; %feedback motif
%FFWs = FFW|FFW.';
%FBs = FB|FB.';
G_ffw = digraph (FFW); %digraph([1 1 3], [2 3 2])
G_fb = digraph(FB);
%% Find Motifs
TM = zeros(50,50); %test matrix
n = length(TM); %number of vertices
P = cell(2,1);
for i=1:n
    for j=1:n
        TM(i,j)=randsample(-1:1,1);
        if i==j
            TM(i,j)=0; %no self-loop
        end
    end
end
cTM=conv2(TM,ones(3,3),'valid');
[k,l]=find((cTM>=-9)&(cTM<=9));
ind=[k,l];
s = zeros(2,length(ind'));
for num=1:length(ind')
    k=ind(num,1); l=ind(num,2);
    SM=TM(k:k+2,l:l+2);
    if SM==FFW
        msg1='feedforward';
    elseif SM==FB
        msg2='feedback';
    end
    G_sm = digraph(SM);
    P{1,num} = isomorphism(G_ffw,G_sm);
    s(1,num) = sum(P{1,num});
    P{2,num} = isomorphism(G_fb,G_sm);
    s(2,num) = sum(P{2,num});
end
id1 = find(s(1,:)~=0);
id2 = find(s(2,:)~=0);