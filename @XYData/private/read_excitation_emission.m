function read_excitation_emission(obj)
% reads the data from the HDF5 file and puts stores in in the XYEE object
% does not modify any of the data apart from permutations 

    %% Preallocating some matrices and reading single groups
    finfo = h5info(obj.fname);
    dimnames = {finfo.Datasets.Name};
    dimsizes = cellfun(@(x)(x.Size),{finfo.Datasets.Dataspace});
    size_excitation = dimsizes(strcmp('excitation_wavelengths', dimnames));
    size_emission = dimsizes(strcmp('emission_wavelengths', dimnames));
    size_power = dimsizes(strcmp('power_measurements', dimnames));
    
    obj.spectrometer.spectra = NaN(obj.xystage.ynum, obj.xystage.xnum, ...
        size_excitation, size_emission);
    obj.powermeter.power = NaN(obj.xystage.ynum, obj.xystage.xnum,...
        size_excitation, size_power);
    obj.powermeter.flux_averaged = NaN(obj.xystage.ynum, ...
        obj.xystage.xnum, size_excitation); 
    obj.xystage.coordinates = NaN(obj.xystage.ynum, obj.xystage.xnum, 2);
    
    % sm_resp = xlsread('QE65000_Efficiency.xlsx');
    
    % rounding the wavelengths is necessary for finding indices later
    obj.spectrometer.wavelengths = round(...
        h5read(obj.fname, '/dark/emission'), 2);
    obj.spectrometer.darkspectrum = h5read(obj.fname, '/dark/spectrum'); 
    obj.laser.excitation_wavelengths = round(...
        h5read(obj.fname, '/x1y1/excitation'), 2); 

    
    if length(obj.laser.excitation_wavelengths) ~= obj.laser.wlnum
        obj.laser.wlnum = length(obj.laser.excitation_wavelengths); 
    end
    
    %% Read in all the measurement data
    
    for y=1:obj.xystage.ynum
        for x=1:obj.xystage.xnum
            group = sprintf('/x%dy%d/', x, y);
            spectrum = h5read(obj.fname, [group 'spectrum']);
            spectrum = permute(spectrum, [2 1]);
            obj.spectrometer.spectra(y, x, :, :) = spectrum;
            power = h5read(obj.fname,  [group 'power']); 
            % take absolute to convert possibly small but negative powers.
            power = abs(permute(power, [2 1])); 
            obj.powermeter.power(y, x, :, :) = power;
            obj.xystage.coordinates(y,x,:) = h5read(obj.fname, ...
                [group 'position']);
        end
    end

    % make time vector for powermeter. One measurement every 5 ms. 
    number_of_samples = round(obj.powermeter.integration_time)/5; 
    obj.powermeter.time = 0:1:(number_of_samples-1)*5; 
    %% Read the beamsplitter calibration file 
    % If no beamsplitter calibration file is found, notify user and prompt with
    % question if they want to manually add a beamsplitter calibration file. 
    
    try
        wavelengths = h5read(obj.fname, ...
            '/calibration_beamsplitter/wavelength'); 
        powers = h5read(obj.fname, ...
            '/calibration_beamsplitter/power'); 
        times = h5read(obj.fname, ...
            '/calibration_beamsplitter/times'); 
    catch EM
        if strcmp(EM.identifier, 'MATLAB:imagesci:h5read:libraryError')
            fig = uifigure;
            msg = ['No beamsplitter calibration data was found. ' ...
                'Do you want to manually select a calibration file?'];
            title = 'No calibration data';
            selection = uiconfirm(fig, msg, title, ...
               'Options',{'Select file', ... 
               'Continue without calibration data'});
            switch selection
                case 'Select file'
                    disp('selecting file')
                    close(fig)
                    clear('fig')
                    fname = uigetfile('*.csv'); 
                    read_calibration_beamsplitter_csv(obj, fname); 
                    return
                case 'Continue without calibration data'
                    disp('continuing without calibration data')
                    close(fig)
                    clear('fig') 
                    return
            end
        end
    end
    
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

