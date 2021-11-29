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
    end
    
    % delete the wavelength range lines from the plot.
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))

    % Pick the type of spectrum to be set.
    switch spectratype
        case 'Emission'
            set_spectra_emission(obj, correctiontype)
        case 'Excitation'
            set_spectra_excitation(obj, correctiontype)
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
        minwl = obj.datapicker.MinWavelengthSpinner.Value; 
        maxwl = obj.datapicker.MaxWavelengthSpinner.Value; 
        idx_minwl = find(obj.spectrometer.wavelengths == minwl);
        idx_maxwl = find(obj.spectrometer.wavelengths == maxwl); 

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
    
    flux = obj.powermeter.flux_normalized(:, :, idx_ex_wls); 

    if beamsplitter_correction
        correction_bs = correct_for_beamsplitter(obj, idx_ex_wls);
        correction_bs = repmat(...
            correction_bs, [1, obj.xystage.ynum, obj.xystage.xnum]);
        correction_bs = permute(correction_bs, [2 3 1]); 
        fluxrepeat = flux.*correction_bs; 
    else
        fluxrepeat = flux; 
    end
end

function correction_bs = correct_for_beamsplitter(obj, idx_ex_wls)
% Multiplies the normalized flux by the beamsplitter calibration
% correction. Interpolates the beamsplitter calibration at the measured
% excitation wavelengths. 
    correction_bs = interp1(obj.beamsplitter.wavelengths, ...
                obj.beamsplitter.correction_pm_to_sample, ...
                obj.laser.excitation_wavelengths(idx_ex_wls)); 
    
end

function set_spectra_excitation(obj) 
end




% 
% 
% 
% 
%     switch correctiontype
%         case 'Raw Spectra'
%             obj.plotdata.spectra_emission = obj.spectrometer.spectra; 
%         case 'Dark Removed' 
%             darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
%                 obj.xystage.xnum, obj.xystage.ynum, ...
%                 obj.laser.wlnum); 
%             darkrepeat = permute(darkrepeat, [2 3 4 1]); 
%             obj.plotdata.spectra_emission = ...
%                 obj.spectrometer.spectra-darkrepeat; 
%         case 'Corrected for Power and Dark'
%             darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
%                 obj.xystage.xnum, obj.xystage.ynum, obj.laser.wlnum); 
%             darkrepeat = permute(darkrepeat, [2 3 4 1]); 
%     
%             wls = repmat(obj.laser.excitation_wavelengths, 1,...
%                 obj.xystage.xnum, obj.xystage.ynum);
%             % change unit from nm to m
%             wls = permute(wls, [2 3 1])*1e-9; 
%     
%             h = 6.626e-34;     % planck constant
%             c = 2.997e8;       % speed of light 
%     
%             power_averaged = mean(obj.powermeter.power, 4); 
%             flux_averaged = power_averaged.* ...
%                 wls./(h*c); 
%             obj.powermeter.flux_normalized = flux_averaged./ ...
%                 max(flux_averaged, [], 3); 
%             
%             % interpolate beamsplitter calibration file with actual 
%             % power measurements
%             correction_beamsplitter = interp1(obj.beamsplitter.wavelengths, ...
%                 obj.beamsplitter.correction_pm_to_sample, ...
%                 obj.laser.excitation_wavelengths); 
%             correction_beamsplitter = repmat(...
%                 correction_beamsplitter, 1, ...
%                 obj.xystage.xnum, obj.xystage.ynum); 
%             correction_beamsplitter = permute(correction_beamsplitter, ...
%                 [2 3 1]); 
%             
%             correction_total = correction_beamsplitter.*flux_averaged;
%             correction_total = correction_total./max(correction_total, [], 3);
%     
%             obj.plotdata.spectra_emission = obj.spectrometer.spectra - ...
%                 darkrepeat; 
%             obj.plotdata.spectra_emission = obj.plotdata.spectra_emission./... 
%                  correction_total; 



