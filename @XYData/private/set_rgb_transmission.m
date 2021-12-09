function obj = set_rgb_transmission(obj)
    % Set the values for the rgb colour chart. The default is the integral
    % of the chosen spectrum type. When fits are done for all the points 
    % on the film, fit results and parameters become options too. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_transmission, 3); 
        return
    end

    parameter = obj.datapicker.ColorChartDropDown.Value;
    switch parameter
        case 'default'
            obj.plotdata.rgb = sum(obj.plotdata.spectra_transmission, 3);
        case 'thickness'
            obj.plotdata.rgb = cellfun(@(x)(x.d), obj.fitdata.fitobjects);
        case 'refractive index (589 nm)'
            n1 = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)));
            obj.plotdata.rgb = cellfun(@(x)(n1(x.an, x.bn, 589)), ...
                obj.fitdata.fitobjects); 
        case coeffnames(obj.fitdata.fitobjects{1,1})
            obj.plotdata.rgb = cellfun(@(x)x.(parameter), ...
                obj.fitdata.fitobjects);
        case fieldnames(obj.fitdata.goodnesses{1,1})
            obj.plotdata.rgb = cellfun(@(x)x.(parameter), ...
                obj.fitdata.goodnesses);
    end
    
end

