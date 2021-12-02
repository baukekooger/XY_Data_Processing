function passed = check_range_spinner(obj, src, event)
% Check when selecting a new value with the uispinner buttons. Checks if
% newly selected value is in range. 

    switch obj.experiment
        case 'transmission'
            passed = check_range_transmission(obj, src, event);
        case 'excitation_emission' 
            passed = check_range_excitation_emission(obj, src, event);
        case 'decay'
            passed = check_range_decay(obj, src, event);
    end
end

function passed = check_range_transmission(obj, src, event)
% Check if selected wavelength is in range and if minimum is smaller than
% maximum.

    minwl_selected = obj.datapicker.MinWavelengthSpinner.Value;
    maxwl_selected = obj.datapicker.MaxWavelengthSpinner.Value;

    minwl = min(obj.plotdata.wavelengths_transmission);
    maxwl = max(obj.plotdata.wavelengths_transmission);

    if minwl_selected < maxwl_selected && ...
            minwl_selected >= minwl && maxwl_selected <= maxwl
        passed = true; 
        return
    else
        set_source_previous_value(src, event)
        passed = false; 
    end
end

function passed = check_range_excitation_emission(obj, src, event) 
% Check if the values selected with the spinners do not violate the maximum
% range of wavelengths, and make sure minima are always smaller than
% maxima. 
    switch src.Tag
        case {'MinWavelengthSpinner', 'MaxWavelengthSpinner'}
            minwl_selected = obj.datapicker.MinWavelengthSpinner.Value;
            maxwl_selected = obj.datapicker.MaxWavelengthSpinner.Value;

            minwl = min(obj.plotdata.wavelengths_emission);
            maxwl = max(obj.plotdata.wavelengths_emission);

            if minwl_selected < maxwl_selected && ...
                    minwl_selected >= minwl && maxwl_selected <= maxwl
                passed = true; 
                return
            else
                set_source_previous_value(src, event)
                passed = false;
            end
               
        case {'EmissionPeakSpinner', 'PeakWidthSpinner'}
            peakwl = obj.datapicker.EmissionPeakSpinner.Value; 
            peakwidth = obj.datapicker.PeakWidthSpinner.Value; 
            
            minwl = min(obj.plotdata.wavelengths_emission);
            maxwl = max(obj.plotdata.wavelengths_emission);

            if peakwl - peakwidth/2 > minwl && peakwl + peakwidth/2 < maxwl
                passed = true; 
                return
            else
                set_source_previous_value(src, event)
                passed = false; 
            end 
        case {'MinExWavelengthSpinner', 'MaxExWavelengthSpinner'}
            minexwl_selected = obj.datapicker.MinExWavelengthSpinner.Value;
            maxexwl_selected = obj.datapicker.MaxExWavelengthSpinner.Value;

            minexwl = min(obj.plotdata.wavelengths_excitation);
            maxexwl = max(obj.plotdata.wavelengths_excitation);

            if minexwl_selected < maxexwl_selected && ...
                minexwl_selected >= minexwl && maxexwl_selected <= maxexwl
                passed = true; 
                return
            else
                set_source_previous_value(src, event)
                passed = false; 
            end
    end
                 
end

function set_source_previous_value(src, event)
    src.Value = event.PreviousValue; 
end


