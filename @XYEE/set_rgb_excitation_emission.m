function obj = set_rgb_excitation_emission(obj)
% Sets the RGB color mapping of the datapicker and plotwindow. This rgb
% value is based on the integral of the selected spectra. For emission, the
% rgb value is the integral of the emission spectrum for all the selected
% excitation wavelengths combined. For excitation, it is the integral of
% the excitation spectrum for the chosen emission wavelengths. 
% instead of actually integrating it just takes the sum as super high
% accuracy is not necessary

% For excitation, it also stores the excitation spectra for the current
% selection of emission wavelengths.

switch obj.datapicker.PlottypeDropDown.Value
    case 'Emission'
        ex_wls = str2double(...
            obj.datapicker.EmissionExcitationWavelengthsListBox.Value); 
        [~, index_wls] = intersect(obj.laser.excitation_wavelengths, ...
            ex_wls); 
        obj.plotdata.rgb = sum(obj.plotdata.spectra_emission(:,:, ...
            index_wls,:), [3 4]); 
%         disp('set rgb emission')
    case 'Excitation'
        em_wls = str2double(...
            obj.datapicker.ExcitationEmissionWavelengthsListBox.Value); 
        [~, index_wls] = intersect(obj.spectrometer.wavelengths, ...
            em_wls); 
        obj.plotdata.spectra_excitation = ...
            sum(obj.plotdata.spectra_emission(:,:,:,index_wls), 4); 
        obj.plotdata.rgb = sum(obj.plotdata.spectra_excitation, 3); 
%         disp('set rgb excitation')
end 

