function set_spectra_transmission(obj)
% Sets the plotdata spectra to raw spectra, subtracted dark or transmission
% spectra depending on the chosen in the datapicker. 
% Trims the data to the selected wavlength range. 
   
    % Set to transmission at initialization when datapicker is not yet
    % initialized. Also initialize empty cells for the fitdata.
    if isempty(obj.datapicker)
        plottype = 'Transmission'; 
        obj.fitdata.fitobjects = cell(obj.xystage.ynum, ...
            obj.xystage.xnum, 1); 
        obj.fitdata.goodnesses = cell(obj.xystage.ynum, ...
            obj.xystage.xnum, 1); 
        obj.fitdata.outputs = cell(obj.xystage.ynum, ...
            obj.xystage.xnum, 1);
        idx_minwl = 1; 
        idx_maxwl = length(obj.spectrometer.wavelengths);
    else
        plottype = obj.datapicker.SpectraDropDown.Value; 
        minwl = obj.datapicker.MinWavelengthSpinner.Value; 
        maxwl = obj.datapicker.MaxWavelengthSpinner.Value; 
        idx_minwl = find(obj.spectrometer.wavelengths == minwl);
        idx_maxwl = find(obj.spectrometer.wavelengths == maxwl); 
    end
    
    % delete the wavelength range lines from the plot.
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))

    % set the ranges of wavelengths, dark and lamp spectrum
    obj.plotdata.wavelengths_transmission = ...
        obj.spectrometer.wavelengths(idx_minwl:idx_maxwl); 
    obj.plotdata.darkspectrum = ...
        obj.spectrometer.darkspectrum(idx_minwl:idx_maxwl); 
    obj.plotdata.lampspectrum = ...
        obj.spectrometer.lampspectrum(idx_minwl:idx_maxwl);

    % set the spectra ranges
    switch plottype
        case 'Raw Data'
            obj.plotdata.spectra_transmission = ...
                obj.spectrometer.spectra(:,:,idx_minwl:idx_maxwl); 
        case 'Dark Removed'
            darkrepeat = repeatdark(obj);
            obj.plotdata.spectra_transmission = ...
                obj.spectrometer.spectra(:,:,idx_minwl:idx_maxwl) ...
                - darkrepeat;
        case 'Transmission'
            darkrepeat = repeatdark(obj);
            lamprepeat = repeatlamp(obj); 
            obj.plotdata.spectra_transmission = ...
                obj.spectrometer.spectra(:,:,idx_minwl:idx_maxwl) ...
                - darkrepeat; 
            obj.plotdata.spectra_transmission = ...
                obj.plotdata.spectra_transmission ./ lamprepeat;
            % Remove NaN and Inf values
            obj.plotdata.spectra_transmission(isnan(...
                obj.plotdata.spectra_transmission)) = 0;
            obj.plotdata.spectra_transmission(isinf(...
                obj.plotdata.spectra_transmission)) = 1;
    end  
end    

function darkrepeat = repeatdark(obj)
    darkrepeat = repmat(obj.plotdata.darkspectrum, 1, ...
            obj.xystage.ynum, obj.xystage.xnum);
    darkrepeat = permute(darkrepeat, [2 3 1]); 
end

function lamprepeat = repeatlamp(obj)
    lamprepeat = repmat(obj.plotdata.lampspectrum, 1, ...
            obj.xystage.ynum, obj.xystage.xnum);
    lamprepeat = permute(lamprepeat, [2 3 1]);
end