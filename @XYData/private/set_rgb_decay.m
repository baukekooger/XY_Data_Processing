function set_rgb_decay(obj) 
% set the rgb plotvalues for the decay measurements. Only make an rgb plot
% which corresponds to the decay time when fitdata is present for all
% selected datapoints. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 
        return
    end

    switch obj.datapicker.ColorChartDropDown.Value
        case 'default'
            obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 
        case {'C', 'C1'}
            obj.plotdata.rgb = cellfun(@(x)(x.a), ...
                obj.fitdata.fitobjects); 
       case {'tau', 'tau_1'} 
            obj.plotdata.rgb = cellfun(@(x)(x.b), ...
                obj.fitdata.fitobjects); 
            % Invert coefficient to get decay time, and multiply by 1e6 to
            % get decay time in microseconds. 
            obj.plotdata.rgb = -1e6./obj.plotdata.rgb; 
       case 'C2' 
            obj.plotdata.rgb = cellfun(@(x)(x.c), ...
                obj.fitdata.fitobjects); 
       case 'tau_2' 
            obj.plotdata.rgb = cellfun(@(x)(x.d), ...
                obj.fitdata.fitobjects); 
            % Invert coefficient to get decay time, and multiply by 1e6 to
            % get decay time in microseconds. 
            obj.plotdata.rgb = -1e6./obj.plotdata.rgb; 
        case 'sse'
            obj.plotdata.rgb = cellfun(@(x)(x.sse), ...
                obj.fitdata.goodnesses); 
        case 'rsquare'
            obj.plotdata.rgb = cellfun(@(x)(x.rsquare), ...
                obj.fitdata.goodnesses);
        case 'dfe'
            obj.plotdata.rgb = cellfun(@(x)(x.dfe), ...
                obj.fitdata.goodnesses);
        case 'adjrsquare'
            obj.plotdata.rgb = cellfun(@(x)(x.adjrsquare), ...
                obj.fitdata.goodnesses);
        case 'rmse'
            obj.plotdata.rgb = cellfun(@(x)(x.rmse), ...
                obj.fitdata.goodnesses);
    end 

end