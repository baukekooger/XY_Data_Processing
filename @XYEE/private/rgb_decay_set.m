function rgb_decay_set(obj) 
% set the rgb plotvalues for the decay measurements. Only make an rgb plot
% which corresponds to the decay time when fitdata is present for all
% selected datapoints. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 
        return
    end

end