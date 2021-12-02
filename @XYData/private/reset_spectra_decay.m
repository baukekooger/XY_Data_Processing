function reset_spectra_decay(obj)
% reset the spectra to the full time range with the current wavelength 
% selection 

    % reset datacompression drop down
    obj.datapicker.DataCompressionDropDown.Value = "none"; 

    % reset the starttime and stoptime spinners to their initial values
    sample_rate = double(obj.digitizer.sample_rate);
    samples = double(obj.digitizer.samples); 

    step = 1 / sample_rate; 
    upperlimit = (samples-1) / sample_rate; 

    obj.datapicker.StartTimeSpinner.Limits = [0 upperlimit];
    obj.datapicker.StartTimeSpinner.Step = step; 
    obj.datapicker.StartTimeSpinner.Value = 0; 
    obj.datapicker.StopTimeSpinner.Limits = [0 upperlimit];
    obj.datapicker.StopTimeSpinner.Step = step;
    obj.datapicker.StopTimeSpinner.Value = upperlimit; 
    
    % get the selected excitation wavelength(s) 
    [~, ex_index] = get_excitation_wavelengths(obj); 
    
    % normalize by dividing spectra through the max the spectra
    obj.plotdata.spectra_decay = obj.digitizer.spectra(:, :, ex_index, :)...
        ./ max(obj.digitizer.spectra(: , :, ex_index, :), [] , 4); 
    obj.plotdata.time_decay = obj.digitizer.time;

end