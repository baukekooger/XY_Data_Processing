function select_nearest_wavelength(obj, src)
% Change the values in the wavelength Spinners to the nearest actual
% wavelength values. 
% The wavelength values are not equally spaced. The spinner step
% is an average of the differences. When selecting the wavelength with
% the cursor, the selection might also not always yield a valid wavelength
% value. This function changes the selection to the nearest valid point.

    switch obj.experiment
        case 'transmission'
            select_nearest_wavelength_transmission(obj)
        case 'excitation_emission'
            select_nearest_wavelength_excitation_emission(obj, src)
    end
end

function select_nearest_wavelength_transmission(obj)
% Select the nearest wavelength value to the actual value in the wavelength
% spinner. 

    minwl_current = obj.datapicker.MinWavelengthSpinner.Value; 
    maxwl_current = obj.datapicker.MaxWavelengthSpinner.Value; 
    wls = obj.plotdata.wavelengths_transmission;
  
    [minwl, ~] = select_nearest(wls, minwl_current);
    [maxwl, ~] = select_nearest(wls, maxwl_current);    

    obj.datapicker.MinWavelengthSpinner.Value = minwl; 
    obj.datapicker.MaxWavelengthSpinner.Value = maxwl; 

end

function select_nearest_wavelength_excitation_emission(obj, src) 
% Select the nearest valid wavelength to the value currently in the 
% spinner, and set the spinner to that value. 
    
    switch src.Tag
        case {'MinWavelengthSpinner', 'MaxWavelengthSpinner'}
            minwl_current = obj.datapicker.MinWavelengthSpinner.Value; 
            maxwl_current = obj.datapicker.MaxWavelengthSpinner.Value; 
            wls = obj.plotdata.wavelengths_emission; 
          
            [minwl, ~] = select_nearest(wls, minwl_current);
            [maxwl, ~] = select_nearest(wls, maxwl_current);

            obj.datapicker.MinWavelengthSpinner.Value = minwl; 
            obj.datapicker.MaxWavelengthSpinner.Value = maxwl; 
    
        case {'EmissionPeakSpinner'}
            peakwl_current = obj.datapicker.EmissionPeakSpinner.Value; 
            wls = obj.plotdata.wavelengths_emission;
            % wls is always a vector of unique values. 
            [peakwl, ~] = select_nearest(wls, peakwl_current); 
            obj.datapicker.EmissionPeakSpinner.Value = peakwl; 
        case {'MinExWavelengthSpinner', 'MaxExWavelengthSpinner'}
            minexwl_current = obj.datapicker.MinExWavelengthSpinner.Value; 
            maxexwl_current = obj.datapicker.MaxExWavelengthSpinner.Value; 
            wls = obj.plotdata.wavelengths_excitation; 
          
            [minwl, ~] = select_nearest(wls, minexwl_current);
            [maxwl, ~] = select_nearest(wls, maxexwl_current);

            obj.datapicker.MinExWavelengthSpinner.Value = minwl; 
            obj.datapicker.MaxExWavelengthSpinner.Value = maxwl; 
    end
end 








