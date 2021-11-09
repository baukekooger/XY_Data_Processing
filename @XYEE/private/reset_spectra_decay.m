function reset_spectra_decay(obj)
% reset the spectra to the full time range with the current wavelength 
% selection 

    % reset the starttime and stoptime spinners to their initial values
    upperlimit = double(obj.digitizer.samples-1) / ... 
        double(obj.digitizer.sample_rate); 
    obj.datapicker.StartTimeSpinner.Value = 0; 
    obj.datapicker.StopTimeSpinner.Value = upperlimit; 
    
    % get the selected excitation wavelength(s) 
    [~, ex_index] = get_excitation_wavelengths(obj); 
    
    % normalize by dividing spectra through the max the spectra
    obj.plotdata.spectra_decay = obj.digitizer.spectra(:, :, ex_index, :)...
        ./ max(obj.digitizer.spectra(: , :, ex_index, :), [] , 4); 
    obj.plotdata.time_decay = obj.digitizer.time;

end

