function obj = set_rgb_transmission(obj)
    % Set the values for the rgb colour chart. The default is the integral
    % of the chosen spectrum type. When fits are done for all the points 
    % on the film, fit parameters become options too. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
    obj.plotdata.rgb = sum(obj.plotdata.spectra_transmission, 3); 
    return
    end
    
end

