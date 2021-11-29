function reset_wavelengths(obj)
% Reset the values of the wavelength spinners to the minimum and maximum
% wavelength present in the spectrometer data. 

    minwl = obj.spectrometer.wavelengths(1); 
    maxwl = obj.spectrometer.wavelengths(end); 
    
    obj.datapicker.MinWavelengthSpinner.Value = minwl; 
    obj.datapicker.MaxWavelengthSpinner.Value = maxwl; 

end

