function obj = set_rgb_excitation_emission(obj)
% Sets the RGB color mapping of the datapicker and plotwindow. The default
% value setting for the rgb values is the integral of the plotdata spectra.
% When fitdata is present, this is also an option. 

    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            set_rgb_emission(obj)
        case 'Excitation'
            set_rgb_excitation(obj)
    end 
end

function set_rgb_emission(obj)
    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_emission, [3 4]); 
        return
    end
end

function set_rgb_excitation(obj)
%     em_wls = str2double(...
%         obj.datapicker.ExcitationEmissionWavelengthsListBox.Value); 
%     [~, index_wls] = intersect(obj.spectrometer.wavelengths, ...
%         em_wls); 
%     obj.plotdata.spectra_excitation = ...
%         sum(obj.plotdata.spectra_emission(:,:,:,index_wls), 4); 
%     obj.plotdata.rgb = sum(obj.plotdata.spectra_excitation, 3); 
%         disp('set rgb excitation')
end