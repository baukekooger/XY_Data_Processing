function set_spectra_excitation_emission(obj) 
% Set the plotdata spectra which are used to make the rgb plots from, as
% well as showing the data in the plotwindow when clicking in the XY
% datapicker. 
% Initialize with default values when there is no instance of the
% datapicker yet. 

    if isempty(obj.datapicker)
        spectratype = 'Emission';
        correctiontype = 'No Correction'; 
        obj.fitdata.fitobjects = cell(obj.xystage.ynum, ...
                obj.xystage.xnum, 1); 
        obj.fitdata.goodnesses = cell(obj.xystage.ynum, ...
            obj.xystage.xnum, 1); 
        obj.fitdata.outputs = cell(obj.xystage.ynum, ...
            obj.xystage.xnum, 1);
    else
        spectratype = obj.datapicker.SpectraDropDown.Value; 
        correctiontype = obj.datapicker.CorrectionDropDown.Value;   
        if not(isempty(obj.plotwindow.ax_spectrum.Legend))
            delete(obj.plotwindow.ax_spectrum.Legend)
        end
    end
    
    % delete the wavelength range lines from the plot.
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))
    
    % Pick the type of spectrum to be set.
    switch spectratype
        case 'Emission'
            set_spectra_emission(obj, correctiontype)
        case 'Excitation'
            set_spectra_excitation(obj, correctiontype)
        case 'Power' 
            set_spectra_power(obj, correctiontype) 
    end
end

function set_spectra_emission(obj, correctiontype)
% Set the emission spectra as the plotdata. Use the full wavelength 
% range when datapicker is not initialized. Otherwise use range 
% from wavelength Spinners. 

    if isempty(obj.datapicker)
        idx_minwl = 1; 
        idx_maxwl = length(obj.spectrometer.wavelengths);
        idx_ex_wls = 1; 
    else
        minwl_selected = obj.datapicker.MinWavelengthSpinner.Value; 
        maxwl_selected = obj.datapicker.MaxWavelengthSpinner.Value; 
        [~, idx_minwl] = select_nearest(...
            obj.spectrometer.wavelengths, minwl_selected);
        [~, idx_maxwl] = select_nearest(...
            obj.spectrometer.wavelengths, maxwl_selected); 

        ex_wl_selection = ...
            obj.datapicker.ExcitationWavelengthsListBox.Value;
        % if single value selected
        if ischar(ex_wl_selection)
            ex_wl_selection = cellstr(ex_wl_selection);
        end
        ex_wl_selection = cellfun(@str2double, ex_wl_selection);
        [~, idx_ex_wls] = intersect(obj.laser.excitation_wavelengths, ...
            ex_wl_selection); 
    end

    obj.plotdata.wavelengths_emission = ...
            obj.spectrometer.wavelengths(idx_minwl:idx_maxwl); 
    obj.plotdata.wavelengths_excitation = ...
            obj.laser.excitation_wavelengths(idx_ex_wls);
    obj.plotdata.darkspectrum_emission = ...
            obj.spectrometer.darkspectrum(idx_minwl:idx_maxwl);

    switch correctiontype
        case 'No Correction'
            obj.plotdata.spectra_emission = ...
                obj.spectrometer.spectra(:, :, idx_ex_wls, ...
                idx_minwl:idx_maxwl); 
        case 'Dark Spectrum'
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, idx_ex_wls);
            obj.plotdata.spectra_emission = ...
                obj.spectrometer.spectra(:, :, idx_ex_wls, ...
                idx_minwl:idx_maxwl) - darkrepeat; 
        case 'Dark Spectrum, Power' 
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, idx_ex_wls);
            fluxrepeat = repeatflux(obj, idx_ex_wls, false);

            obj.plotdata.spectra_emission = ... 
                obj.spectrometer.spectra(:, :, idx_ex_wls, ...
                idx_minwl:idx_maxwl) - darkrepeat; 
            obj.plotdata.spectra_emission = ...
                obj.plotdata.spectra_emission ./ fluxrepeat; 
              
        case 'Dark Spectrum, Power, Beamsplitter' 
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, idx_ex_wls);
            fluxrepeat = repeatflux(obj, idx_ex_wls, true);

            obj.plotdata.spectra_emission = ... 
                obj.spectrometer.spectra(:, :, idx_ex_wls, ...
                idx_minwl:idx_maxwl) - darkrepeat; 
            obj.plotdata.spectra_emission = ...
                obj.plotdata.spectra_emission ./ fluxrepeat; 
    end
end

function set_spectra_excitation(obj, correctiontype) 
% Calculate the excitation spectra by summing the selected emission range
% for all the excitation wavelengths. Apply correction according to the
% selected option. 
    emissionpeak = obj.datapicker.EmissionPeakSpinner.Value; 
    peakwidth = obj.datapicker.PeakWidthSpinner.Value; 
    wls = obj.spectrometer.wavelengths; 
    [~, idx_minwl] = select_nearest(wls, emissionpeak-0.5*peakwidth); 
    [~, idx_maxwl] = select_nearest(wls, emissionpeak+0.5*peakwidth); 
    
    excitation_min = obj.datapicker.MinExWavelengthSpinner.Value; 
    excitation_max = obj.datapicker.MaxExWavelengthSpinner.Value; 
    exwls = obj.laser.excitation_wavelengths; 

    [~, idx_minexwl] = select_nearest(exwls, excitation_min); 
    [~, idx_maxexwl] = select_nearest(exwls, excitation_max); 

    obj.plotdata.wavelengths_excitation = ...
        obj.laser.excitation_wavelengths(idx_minexwl:idx_maxexwl); 
    switch correctiontype
        case 'No Correction'
            obj.plotdata.spectra_excitation = ...
                sum(obj.spectrometer.spectra(:, :, ...
                idx_minexwl:idx_maxexwl, idx_minwl:idx_maxwl), 4); 
        case 'Dark Spectrum'
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, ...
                idx_minexwl:idx_maxexwl);
            spectra_corrected = obj.spectrometer.spectra(:, :, ...
                idx_minexwl:idx_maxexwl, idx_minwl:idx_maxwl) - darkrepeat; 
            obj.plotdata.spectra_excitation = sum(spectra_corrected, 4); 
        case 'Dark Spectrum, Power' 
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, ...
                idx_minexwl:idx_maxexwl);
            fluxrepeat = repeatflux(obj, idx_minexwl:idx_maxexwl, false);
            spectra_corrected = obj.spectrometer.spectra(:, :, ...
                idx_minexwl:idx_maxexwl, idx_minwl:idx_maxwl) - darkrepeat; 
            spectra_corrected = spectra_corrected./ fluxrepeat; 
            obj.plotdata.spectra_excitation = sum(spectra_corrected, 4); 
        case 'Dark Spectrum, Power, Beamsplitter' 
            darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, ...
                idx_minexwl:idx_maxexwl);
            fluxrepeat = repeatflux(obj, idx_minexwl:idx_maxexwl, true);
            spectra_corrected = obj.spectrometer.spectra(:, :, ...
                idx_minexwl:idx_maxexwl, idx_minwl:idx_maxwl) - darkrepeat; 
            spectra_corrected = spectra_corrected./ fluxrepeat; 
            obj.plotdata.spectra_excitation = sum(spectra_corrected, 4); 
    end
end

function set_spectra_power(obj, correctiontype)
% Set the power spectra to plot according to the chosen correctiontype. 
    excitation_min = obj.datapicker.MinExWavelengthSpinner.Value; 
    excitation_max = obj.datapicker.MaxExWavelengthSpinner.Value; 
    exwls = obj.laser.excitation_wavelengths; 

    [~, idx_minexwl] = select_nearest(exwls, excitation_min); 
    [~, idx_maxexwl] = select_nearest(exwls, excitation_max); 

    obj.plotdata.wavelengths_excitation = ...
        obj.laser.excitation_wavelengths(idx_minexwl:idx_maxexwl);

    switch correctiontype
        case 'Power at Meter'
            obj.plotdata.power_excitation = ...
                get_average_powermeter(obj, idx_minexwl:idx_maxexwl, ...
                'power_averaged'); 
        case 'Power at Sample (corrected for beamsplitter)'
            correction_bs = correct_for_beamsplitter(obj, ...
                idx_minexwl:idx_maxexwl);
            correction_bs = repeat_columnvector(obj, correction_bs); 
            power_averaged_meter = get_average_powermeter(obj, ...
                idx_minexwl:idx_maxexwl, 'power_averaged'); 
            obj.plotdata.power_excitation = power_averaged_meter .* ...
                correction_bs; 
        case 'Photon Flux at Meter'
            obj.plotdata.power_excitation = ...
                get_average_powermeter(obj, idx_minexwl:idx_maxexwl, ...
                'flux_averaged'); 
        case 'Photon Flux at Sample (corrected for beamsplitter)'
            correction_bs = correct_for_beamsplitter(obj, ...
                idx_minexwl:idx_maxexwl);
            correction_bs = repeat_columnvector(obj, correction_bs); 
            power_averaged_meter = get_average_powermeter(obj, ...
                idx_minexwl:idx_maxexwl, 'flux_averaged'); 
            obj.plotdata.power_excitation = power_averaged_meter .* ...
                correction_bs; 
    end
end

function darkrepeat = repeatdark(obj, idx_minwl, idx_maxwl, idx_ex_wls)
% Repeat dark spectra to subtract from the emission spectra for the
% relevant emission and excitation wavelengths. 
    wlnum = length(idx_ex_wls); 
    darkrepeat = repmat(obj.spectrometer.darkspectrum(...
        idx_minwl:idx_maxwl), 1, obj.xystage.ynum, ...
        obj.xystage.xnum, wlnum); 
    darkrepeat = permute(darkrepeat, [2 3 4 1]); 
end

function fluxrepeat = repeatflux(obj, idx_ex_wls, beamsplitter_correction)
% Calculate the light flux from the measured power and make a repeated 
% matrix of the result to divide the spectra by. If beamsplitter correction
% is true, also correct for the beamsplitter calibration.  
    arguments
        obj                         (1,1) XYData
        idx_ex_wls                  (:,1) double
        beamsplitter_correction     (1,1) {mustBeNumericOrLogical}
    end
    
    flux = get_average_powermeter(obj, idx_ex_wls, 'flux_normalized'); 

    if beamsplitter_correction
        correction_bs = correct_for_beamsplitter(obj, idx_ex_wls);
        correction_bs = repeat_columnvector(obj, correction_bs); 
        fluxrepeat = flux.*correction_bs; 
    else
        fluxrepeat = flux; 
    end
end

function average = get_average_powermeter(obj, idx_exwls, type)
% Get the average power, average normalized power, average flux or average
% normalized flux from the powermeter depending on the input type. 

    arguments
        obj (1,1) XYData
        idx_exwls (:, 1) double {mustBePositive}
        type string
    end

    % define constants for setting the averaged photon flux from the power.
    h = 6.626e-34;     % planck constant
    c = 2.997e8;       % speed of light 
    ex_wls = obj.laser.excitation_wavelengths * 1e-9; % wavelengths in nm

    power_averaged = mean(obj.powermeter.power(: , :,idx_exwls,:), 4); 
    switch type
        case 'power_averaged'
            average = power_averaged; 
        case 'power_normalized'
            average = power_averaged ./ max(power_averaged, [], 'all');
        case 'flux_averaged'
            wls = repeat_columnvector(obj, ex_wls(idx_exwls)); 
            average = power_averaged.* wls / (h * c);
        case 'flux_normalized' 
            wls = repeat_columnvector(obj, ex_wls(idx_exwls)); 
            average = power_averaged.* wls / (h * c);
            average = average ./ max(average, [], 'all');
    end     
end

function vectorout = repeat_columnvector(obj, vector)
% Repeats a column vector for every x and y point. 

    arguments
        obj (1,1) XYData
        vector (:,1) double
    end

    ynum = obj.xystage.ynum; 
    xnum = obj.xystage.xnum; 

    vectorout = repmat(vector, 1, ynum, xnum); 
    vectorout = permute(vectorout, [2 3 1]); 
end

function correction_bs = correct_for_beamsplitter(obj, idx_ex_wls)
% Multiply the normalized flux by the beamsplitter calibration
% correction. Interpolate the beamsplitter calibration at the measured
% excitation wavelengths. 
    correction_bs = interp1(obj.beamsplitter.wavelengths, ...
                obj.beamsplitter.correction_pm_to_sample, ...
                obj.laser.excitation_wavelengths(idx_ex_wls), ...
                'linear', 'extrap'); 
    
end
