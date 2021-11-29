function assert_checkboxes_wavelength(obj, src)
% Check if not both checkboxes for clicking wavelength limit are enabled.
% If they are both enabled, disable the one that has not been called. 

    checkmin = obj.datapicker.ClickMinWavelengthCheckBox.Value;
    checkmax = obj.datapicker.ClickMaxWavelengthCheckBox.Value; 
    
    if not(all([checkmin, checkmax])) 
        return
    end
    
    if src == obj.datapicker.ClickMinWavelengthCheckBox
        obj.datapicker.ClickMaxWavelengthCheckBox.Value = 0;
    elseif src == obj.datapicker.ClickMaxWavelengthCheckBox
        obj.datapicker.ClickMinWavelengthCheckBox.Value = 0; 
    else
        error(['Checkbox source does not correspond to checkbox objects'...
            ' in function - check naming'])
    end

end
