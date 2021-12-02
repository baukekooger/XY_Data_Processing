function [datatiptext, passed, src] = ...
    check_range_wavelength_cursor_excitation_emission(obj, event)
% Perform checks if actions need to be taken when clicking in the
% plotwindow. 
% Further action depends on the open tab in the datapicker spectra
% selection, and the selected checkboxes.

    spectratype = obj.datapicker.SpectraDropDown.Value; 
    tab = obj.datapicker.TabGroup.SelectedTab.Title; 
    switch spectratype
        case 'Emission'
            if strcmp(tab, 'Emission')
                [datatiptext, passed, src] = ...
                check_emission_range(obj, event);
            elseif strcmp(tab, 'Excitation')
                [datatiptext, passed, src] = ...
                    check_emission_peak(obj, event);
            end
        case 'Excitation'
            [datatiptext, passed, src] = ...
                check_excitation_range(obj, event);
    end
end

function [datatiptext, passed, src] = check_emission_range(obj, event)
% Check if the minimum selected emission wavelength is smaller than the
% maximum. Do nothing if no checkboxes are enabled. 

    % return true if limit changed, false if limit unchanged.  
    passed = false;
    src = 'None';
    checkmin = obj.datapicker.ClickMinWavelengthCheckBox.Value; 
    checkmax = obj.datapicker.ClickMaxWavelengthCheckBox.Value;
    
    % don't do anything if the checkboxes are not enabled. Only one can be
    % enabled at a time. 
    if not(any([checkmin, checkmax]))
        datatiptext = sprintf('%.2f', event.Position(1));  
        return 
    end 
    
    % get the cursor info and remove any tips if there are more than one. 
    cursorinfo = obj.datacursor.plotwindow.getCursorInfo; 
    % if there are multiple cursor tips, the last one is the initial click. 
    cursorinfo = cursorinfo(end); 
    wl_selected = cursorinfo.Position(1); 
    
    if checkmin
        if wl_selected >= obj.datapicker.MaxWavelengthSpinner.Value
            datatiptext = ['Minimum wavelength must be smaller than ' ...
                'maximum wavelength'];
            return
        end
        obj.datapicker.MinWavelengthSpinner.Value = wl_selected; 
        src = obj.datapicker.MinWavelengthSpinner; 
    elseif checkmax
        if wl_selected <= obj.datapicker.MinWavelengthSpinner.Value
            datatiptext = ['Maximum wavelength must be larger than ' ...
                'minimum wavelength']; 
            return
        end
        obj.datapicker.MaxWavelengthSpinner.Value = wl_selected; 
        src = obj.datapicker.MaxWavelengthSpinner; 
    else 
        error(['neither check start nor check stop enabled but still ' ...
            'executed set time limit function'])
    end

    datatiptext = sprintf('%.2f', event.Position(1));
    passed = true; 

end

function [datatiptext, passed, src] = check_emission_peak(obj, event)
% Check if the selected emission peak and peak width are within the 
% plotted emission wavelength range. 

    % return true if limit changed, false if limit unchanged.  
    passed = false;
    src = 'None'; 
    checkpeak = obj.datapicker.ClickEmissionPeakCheckBox.Value; 
    peak_width = obj.datapicker.PeakWidthSpinner.Value; 
    
    % don't do anything when the checkbox is not clicked. 
    if not(checkpeak)
        datatiptext = sprintf('%.2f', event.Position(1)); 
        return 
    end

    % get the cursor info and remove any tips if there are more than one. 
    cursorinfo = obj.datacursor.plotwindow.getCursorInfo; 
    % if there are multiple cursor tips, the last one is the initial click. 
    cursorinfo = cursorinfo(end); 
    wl_selected = cursorinfo.Position(1); 

    if wl_selected - peak_width/2 < ...
            min(obj.plotdata.wavelengths_emission)
        datatiptext = ['Chosen peak and width have limit lower than ' ...
            'minimum wavelength']; 
        return
    elseif wl_selected + peak_width/2 > ...
            max(obj.plotdata.wavelengths_emission)
        datatiptext = ['Chosen peak and width have limit higher' ...
            'than maximum wavelength']; 
        return
    end
    
    obj.datapicker.EmissionPeakSpinner.Value = wl_selected; 
    src = obj.datapicker.EmissionPeakSpinner; 
    datatiptext = sprintf('%.2f', wl_selected); 
    passed = true;

end

function [datatiptext, passed, src] = check_excitation_range(obj, event)
% Check if the minimum selected excitation wavelength is smaller than the
% maximum. Do nothing if no checkboxes are enabled. 

    % return true if limit changed, false if limit unchanged.  
    passed = false;
    src = 'None'; 
    checkmin = obj.datapicker.ClickMinExWavelengthCheckBox.Value; 
    checkmax = obj.datapicker.ClickMaxExWavelengthCheckBox.Value;
    
    % don't do anything if the checkboxes are not enabled. Only one can be
    % enabled at a time. 
    if not(any([checkmin, checkmax]))
        datatiptext = sprintf('%.2f', event.Position(1)); 
        return 
    end 
    
    % get the cursor info and remove any tips if there are more than one. 
    cursorinfo = obj.datacursor.plotwindow.getCursorInfo; 
    % if there are multiple cursor tips, the last one is the initial click. 
    cursorinfo = cursorinfo(end); 
    wl_selected = cursorinfo.Position(1); 
    
    if checkmin
        if wl_selected >= obj.datapicker.MaxExWavelengthSpinner.Value
            datatiptext = ['Minimum wavelength must be smaller than ' ...
                'maximum wavelength'];
            return
        end
        obj.datapicker.MinExWavelengthSpinner.Value = wl_selected; 
        src = obj.datapicker.MinExWavelengthSpinner;
    elseif checkmax
        if wl_selected <= obj.datapicker.MinExWavelengthSpinner.Value
            datatiptext = ['Maximum wavelength must be larger than ' ...
                'minimum wavelength']; 
            return
        end
        obj.datapicker.MaxExWavelengthSpinner.Value = wl_selected; 
        src = obj.datapicker.MaxExWavelengthSpinner; 
    else 
        error(['neither check start nor check stop enabled but still ' ...
            'executed set time limit function'])
    end

    datatiptext = sprintf('%.2f', event.Position(1));
    passed = true; 

end
        
