function assert_checkboxes_wavelength(obj, src)
% Check if not both checkboxes for clicking wavelength limit are enabled.
% If they are both enabled, disable the one that has not been called. 

    switch src.Tag
        case {'ClickMinWavelengthCheckBox', 'ClickMaxWavelengthCheckBox'}
            assert_checkboxes_emission(obj, src)
        case {'ClickMinExWavelengthCheckBox', ...
                'ClickMaxExWavelengthCheckBox'}
            assert_checkboxes_excitation(obj, src)
    end
end

function assert_checkboxes_emission(obj, src)
% Check that not both of the click wavelength boxes are enabled for the
% emission tab. 
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

function assert_checkboxes_excitation(obj, src)
% Check that not both of the click wavelength boxes are enabled for the
% excitation tab. 
    checkmin = obj.datapicker.ClickMinExWavelengthCheckBox.Value;
    checkmax = obj.datapicker.ClickMaxExWavelengthCheckBox.Value; 
    if not(all([checkmin, checkmax])) 
         return
    end
    if src == obj.datapicker.ClickMinExWavelengthCheckBox
        obj.datapicker.ClickMaxExWavelengthCheckBox.Value = 0;
    elseif src == obj.datapicker.ClickMaxExWavelengthCheckBox
        obj.datapicker.ClickMinExWavelengthCheckBox.Value = 0; 
    else
        error(['Checkbox source does not correspond to checkbox objects'...
        ' in function - check naming'])
    end
end 