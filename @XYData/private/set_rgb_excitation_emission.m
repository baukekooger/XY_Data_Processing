function obj = set_rgb_excitation_emission(obj)
% Sets the RGB color mapping of the datapicker and plotwindow. The default
% value setting for the rgb values is the integral of the plotdata spectra.
% When fitdata is present, this is also an option. 

    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            set_rgb_emission(obj)
        case 'Excitation'
            set_rgb_excitation(obj)
        case 'Power'
            set_rgb_power(obj)
    end 
end

function set_rgb_emission(obj)
    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_emission, [3 4]); 
        return
    end
end

function set_rgb_excitation(obj)
    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_excitation, 3); 
        return
    end
end

function set_rgb_power(obj)
    obj.plotdata.rgb = sum(obj.plotdata.power_excitation, 3); 
end