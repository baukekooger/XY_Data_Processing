function passed = check_beamsplitter_excitation_wavelengths(obj, src, event)
% Checks if the currently selected excitation wavelengths are within the
% range of the beamsplitter calibration file. If not, it prompts the user
% to either change the range or the beamsplitter calibration file, or
% continue with extrapolation. 
% Check only happens during excitation when correction including
% beamsplitter is selected. 
    spectrum = obj.datapicker.SpectraDropDown.Value; 
    correctiontype = obj.datapicker.CorrectionDropDown.Value; 

    if not(strcmp(correctiontype, 'Dark Spectrum, Power, Beamsplitter'))
        passed = true;
        return
    end
    
    switch spectrum
        case 'Emission'
            exwls = str2double(...
                string(obj.datapicker.ExcitationWavelengthsListBox.Value));
            excitation_min = min(exwls); 
            excitation_max = max(exwls); 
        case 'Excitation'
            excitation_min = obj.datapicker.MinExWavelengthSpinner.Value; 
            excitation_max = obj.datapicker.MaxExWavelengthSpinner.Value;
    end
     
    if excitation_min < min(obj.beamsplitter.wavelengths) || ...
            excitation_max > max(obj.beamsplitter.wavelengths)
        fig = uifigure;
        msg = ['Selected excitation wavelengths exceed range of ' ...
            'beamsplitter calibration file. Either continue ' ...
            'with extrapolation of the calibration file, select ' ...
            'a different calibration file or select a smaller' ...
            ' excitation wavelength range.'];
        title = 'Exceeded range beamsplitter calibration.';
        selection = uiconfirm(fig, msg, title, ...
           'Options',{'Continue with extrapolation', ... 
           'Cancel'});
        switch selection
            case 'Continue with extrapolation'
                close(fig)
                clear('fig')
                passed = true; 
                return
            case 'Cancel'
                close(fig)
                clear('fig') 
                passed = false;
                if src == obj.datapicker.SpectraDropDown || ...
                        src == obj.datapicker.CorrectionDropDown
                    src.Value = event.PreviousValue; 
                end
                return
        end
    else
        passed = true;
    end

end

