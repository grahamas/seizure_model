function tmp_ramp_decay = template_rampthendecay(T, fact_durramp, fact_decay)
lenT = length(T); 

tmp_ramp_decay = zeros(1, lenT); 
dur_ramp = ceil(fact_durramp*lenT);
tmp_ramp_decay(1:dur_ramp) = linspace(0,1,dur_ramp); 
tmp_ramp_decay(dur_ramp+1:end) = exp(-(0:(lenT-dur_ramp-1))/(fact_decay*T(end))); 

end
