function obj = fit_single_emission(obj, idy, idx, ex_index)
% Fit single decay signal with the currently selected fittype

    wavelengths = obj.plotdata.wavelengths_emission; 
    spectrum = squeeze(obj.plotdata.spectra_emission(idy, ...
        idx, ex_index, :));
    
    % Make sure both vectors are column vectors. 
    [wavelengths, spectrum] = prepareCurveData(wavelengths, spectrum); 

    [obj.fitdata.fitobjects{idy, idx, ex_index}, ...
        obj.fitdata.goodnesses{idy, idx, ex_index}, ...
        obj.fitdata.outputs{idy, idx, ex_index}] = ...,
        fit(wavelengths, spectrum, obj.fitdata.fittype); 
end