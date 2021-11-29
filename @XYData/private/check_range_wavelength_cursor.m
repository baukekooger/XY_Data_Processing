function changed =  check_range_wavelength_cursor(obj)
% Set the wavelength range for min or max wavelength by clicking in the 
% spectrum plot. The min or max wavelength will only changed if the 
% checkbox for click minimum (or maximum) wavelength is enabled, 
% and if the minimum wavelength by clicking is smaller than the maximum. 

    % return true if limit changed, false if limit unchanged.  
    changed = false;
    checkmin = obj.datapicker.ClickMinWavelengthCheckBox.Value; 
    checkmax = obj.datapicker.ClickMaxWavelengthCheckBox.Value;
    
    % don't do anything if the checkboxes are not enabled. Only one can be
    % enabled at a time. 
    if not(any([checkmin, checkmax]))
        return 
    end 
    
    % get the cursor info and remove any tips if there are more than one. 
    cursorinfo = obj.datacursor.plotwindow.getCursorInfo; 
    % if there are multiple cursor tips, the last one is the initial click. 
    cursorinfo = cursorinfo(end); 
    wl_selected = cursorinfo.Position(1); 
    
    if checkmin
        if wl_selected >= obj.datapicker.MaxWavelengthSpinner.Value
            return
        end
        obj.datapicker.MinWavelengthSpinner.Value = wl_selected; 
    elseif checkmax
        if wl_selected <= obj.datapicker.MinWavelengthSpinner.Value
            return
        end
        obj.datapicker.MaxWavelengthSpinner.Value = wl_selected; 
    else 
        error(['neither check start nor check stop enabled but still ' ...
            'executed set time limit function'])
    end
    changed = true; 
end

