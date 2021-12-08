function obj = fit_single_excitation(obj, idy, idx)
% Fit single decay signal with the currently selected fittype

    wavelengths = obj.plotdata.wavelengths_excitation; 
    spectrum = squeeze(obj.plotdata.spectra_excitation(idy, ...
        idx, :));
    
    % Make sure both vectors are column vectors. 
    [wavelengths, spectrum] = prepareCurveData(wavelengths, spectrum); 
    
    [obj.fitdata.fitobjects{idy, idx}, ...
        obj.fitdata.goodnesses{idy, idx}, ...
        obj.fitdata.outputs{idy, idx}] = ...
        fit(wavelengths, spectrum, obj.fitdata.fittype); 
end