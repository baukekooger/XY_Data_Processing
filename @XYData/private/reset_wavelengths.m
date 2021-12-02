function reset_wavelengths(obj)
% Reset the values of the wavelength spinners to the minimum and maximum
% wavelength present in the spectrometer data. 

    minwl = obj.spectrometer.wavelengths(1); 
    maxwl = obj.spectrometer.wavelengths(end); 
    
    obj.datapicker.MinWavelengthSpinner.Value = minwl; 
    obj.datapicker.MaxWavelengthSpinner.Value = maxwl; 

    if strcmp(obj.experiment, 'excitation_emission')
        minexwl = obj.laser.excitation_wavelengths(1); 
        maxexwl = obj.laser.excitation_wavelengths(end); 
        
        obj.datapicker.MinExWavelengthSpinner.Value = minexwl; 
        obj.datapicker.MaxExWavelengthSpinner.Value = maxexwl; 
    end
end

