function [ex_wls, ex_index] = get_excitation_wavelengths(obj)
% get the excitation wavelengths and index selected in the ui. 
    ex_wls = str2double(obj.datapicker.ExcitationWavelengthListBox.Value);
    [~, ex_index, ~] = intersect(obj.laser.excitation_wavelengths, ...
                ex_wls); 
end