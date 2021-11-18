function obj = fit_single_trace_decay(obj, idy, idx, ex_index)
% Fit single decay signal with the currently selected fittype

    time = obj.plotdata.time_decay'; 
    spectrum = squeeze(obj.plotdata.spectra_decay(idy, idx, ex_index, :));
    
    [obj.fitdata.fitobjects{idy, idx, ex_index}, ...
        obj.fitdata.goodnesses{idy, idx, ex_index}, ...
        obj.fitdata.outputs{idy, idx, ex_index}] = ...,
        fit(time, spectrum, obj.fitdata.fittype); 
end