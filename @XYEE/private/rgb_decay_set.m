function rgb_decay_set(obj) 
% set the rgb plotvalues for the decay measurements.

obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 

end