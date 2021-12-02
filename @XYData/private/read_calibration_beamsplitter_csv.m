function read_calibration_beamsplitter_csv(obj, fname)
% Read a beamsplitter calibration csv file and store the calibration data
% in the beamsplitter attributes.  

    arguments
        obj XYData
        fname string
    end

    model = extractBetween(fname, 'BSC_', '_'); 
    obj.beamsplitter.model = cell2mat(model);
    calibration_date = extractBetween(fname, 'nm_', '.csv'); 
    obj.beamsplitter.calibration_date = cell2mat(calibration_date); 

    importoptions = detectImportOptions(fname); 
    data = readmatrix(fname, importoptions); 
    
    wavelengths = data(:, 2); 
    powers = data(:, 4); 
    times = data(:, 5); 

    total_samples = length(wavelengths); 
    wavelengths_unique = unique(wavelengths);
    number_of_unique_wavelengths = length(wavelengths_unique);
    % factor of two comes from two positions of the powermeter. 
    samples_per_wavelength = total_samples/ ...
        (2 * number_of_unique_wavelengths); 
    
    power_pm = powers(1:total_samples/2); 
    times_pm = times(1:total_samples/2); 
    power_sample = powers(total_samples/2+1:end); 
    times_sample = times(total_samples/2+1:end); 

    obj.beamsplitter.wavelengths = wavelengths_unique;

    obj.beamsplitter.power_pm = reshape(power_pm, ...
        samples_per_wavelength, number_of_unique_wavelengths)'; 
    obj.beamsplitter.times_pm = reshape(times_pm, ...
        samples_per_wavelength, number_of_unique_wavelengths)'; 
    obj.beamsplitter.power_sample = reshape(power_sample, ...
        samples_per_wavelength, number_of_unique_wavelengths)'; 
    obj.beamsplitter.times_sample = reshape(times_sample, ...
        samples_per_wavelength, number_of_unique_wavelengths)'; 
    
    mean_pm = mean(obj.beamsplitter.power_pm, 2);
    mean_sample = mean(obj.beamsplitter.power_sample, 2);
    
    obj.beamsplitter.correction_pm_to_sample = ...
        mean_sample./(mean_pm);

end

