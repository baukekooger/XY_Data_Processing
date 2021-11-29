function select_nearest_wavelength(obj)
% Change the values in the wavelength Spinners to the nearest actual
% wavelength values. 
% The wavelength values are not equally spaced. The spinner step
% is an average of the differences. When selecting the wavelength with
% the cursor, the selection might also not always yield a valid wavelength
% value. This function changes the selection to the nearest valid point.

    minwl_current = obj.datapicker.MinWavelengthSpinner.Value; 
    maxwl_current = obj.datapicker.MaxWavelengthSpinner.Value; 
    
    if strcmp(obj.experiment, 'transmission')
        wls = obj.plotdata.wavelengths_transmission;
    elseif strcmp(obj.experiment, 'excitation_emission')
        wls = obj.plotdata.wavelengths_emission;
    else
        error('Invalid experiment in selecting nearest wavelength')
    end
    % wls is always a vector of unique values. 
    [~, idx_minwl] = min(abs(wls-minwl_current)); 
    [~, idx_maxwl] = min(abs(wls-maxwl_current)); 

    minwl = wls(idx_minwl); 
    maxwl = wls(idx_maxwl); 

    obj.datapicker.MinWavelengthSpinner.Value = minwl; 
    obj.datapicker.MaxWavelengthSpinner.Value = maxwl; 

end


