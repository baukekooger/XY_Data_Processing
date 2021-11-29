function draw_lines_wavelength_range(obj)
% Draw lines in the plotwindow indicating the wavelength range to be
% selected. 

    minwl = obj.datapicker.MinWavelengthSpinner.Value; 
    maxwl = obj.datapicker.MaxWavelengthSpinner.Value; 
    
    if strcmp(obj.experiment, 'transmission')
        idx_minwl = find(obj.plotdata.wavelengths_transmission == minwl); 
        idx_maxwl = find(obj.plotdata.wavelengths_transmission == maxwl); 
    elseif strcmp(obj.experiment, 'excitation_emission') 
        idx_minwl = find(obj.plotdata.wavelengths_emission == minwl); 
        idx_maxwl = find(obj.plotdata.wavelengths_emission == maxwl); 
    else
        error('Invalid experiment draw wavelength range')
    end

    % Do nothing if any of the indexes is outside of the range 
    if isempty(any([idx_minwl, idx_maxwl]))
        return 
    end
    
    % Remove the old lines 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))
    % Plot the new lines 
    linestart = xline(obj.plotwindow.ax_spectrum, minwl); 
    linestart.Label = 'from here'; 
    linestart.LabelVerticalAlignment = 'middle';
    linestart.LabelHorizontalAlignment = 'right'; 
    
    linestop = xline(obj.plotwindow.ax_spectrum, maxwl); 
    linestop.Label = 'till here'; 
    linestop.LabelVerticalAlignment = 'middle';
    linestop.LabelHorizontalAlignment = 'left'; 

end

