function passed = check_range_wavelength_spinner(obj, src, event)
% Check when selecting a new wavelength with the uispinner buttons. 
% Minimum wavelength must be smaller than maximum wavelength.

    % check if stop value is lower than start value
    minwl = obj.datapicker.MinWavelengthSpinner.Value;
    maxwl = obj.datapicker.MaxWavelengthSpinner.Value;
    if minwl < maxwl
        passed = true; 
        return
    end
    % set spinner to previous value if stop lower than start
    if strcmp(src.Tag, 'MinWavelengthSpinner')
        obj.datapicker.MinWavelengthSpinner.Value = event.PreviousValue; 
    elseif strcmp(src.Tag, 'MaxWavelengthSpinner') 
        obj.datapicker.MaxWavelengthSpinner.Value = event.PreviousValue; 
    else
        error(['source tag not equal to MinWavelengthSpinner or ' ...
            'MaxWavelengthSpinner'])
    end
    passed = false; 
end


