% Intrinsic constant parameters  
lst_nrn_prm = fieldnames(exc_nrn); 
intr_var_strct = struct(); 
for i = 1:length(lst_nrn_prm)
    prm_i = lst_nrn_prm{i};
    tmp_i = zeros(num_neurons,1); 
    tmp_i(PE) = exc_nrn.(prm_i); 
    tmp_i(PI) = inh_nrn.(prm_i); 
    intr_var_strct.(prm_i) = tmp_i; 
end

C       	=	intr_var_strct.C;
E_K     	=	intr_var_strct.E_K;
E_L     	=	intr_var_strct.E_L;
E_Na    	=	intr_var_strct.E_Na;
SA      	=	intr_var_strct.SA;
Vm_half 	=	intr_var_strct.Vm_half;
Vn_half 	=	intr_var_strct.Vn_half;
g_K_max 	=	intr_var_strct.g_K_max;
g_L     	=	intr_var_strct.g_L;
g_Na_max	=	intr_var_strct.g_Na_max;
km      	=	intr_var_strct.km;
kn      	=	intr_var_strct.kn;
taun    	=	intr_var_strct.taun;

clear prm_i exc_nrn inh_nrn intr_var_strct
