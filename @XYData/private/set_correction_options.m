function obj = set_correction_options(obj, event)
% Set the correction opions of the correction dropdown based on the chosen
% value. 

switch event.Value
    case {'Emission', 'Excitation'}
        options = {'No Correction', 'Dark Spectrum', ...
            'Dark Spectrum, Power', 'Dark Spectrum, Power, Beamsplitter'};
        obj.datapicker.CorrectionDropDown.Items = options; 
    case 'Power'
        options = {'Power at Meter', ...
            'Power at Sample (corrected for beamsplitter)', ...
            'Photon Flux at Meter', ...
            'Photon Flux at Sample (corrected for beamsplitter)'}; 
        obj.datapicker.CorrectionDropDown.Items = options; 
end

