function obj = set_rgb_transmission(obj)
    % Set the values for the rgb colour chart. The default is the integral
    % of the chosen spectrum type. When fits are done for all the points 
    % on the film, fit parameters become options too. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_transmission, 3); 
        return
    end

    switch obj.datapicker.ColorChartDropDown.Value
        case 'default'
            obj.plotdata.rgb = sum(obj.plotdata.spectra_transmission, 3);
        case 'thickness'
            obj.plotdata.rgb = cellfun(@(x)(x.d), obj.fitdata.fitobjects);
        case 'refractive index (589 nm)'
            n1 = @(a, b, x)( sqrt( 1 + a .* x.^2 ./ (x.^2 - b.^2)));
            obj.plotdata.rgb = cellfun(@(x)(n1(x.an, x.bn, 589)), ...
                obj.fitdata.fitobjects); 
        case 'extinction coefficient'
            obj.plotdata.rgb = cellfun(@(x)(x.ak), obj.fitdata.fitobjects); 
        case 'fit quality (adj.rsquare)' 
            obj.plotdata.rgb = cellfun(@(x)(x.adjrsquare), ...
                obj.fitdata.goodnesses);
    end
    
end

