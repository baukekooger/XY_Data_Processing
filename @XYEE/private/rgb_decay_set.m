function rgb_decay_set(obj) 
% set the rgb plotvalues for the decay measurements. Only make an rgb plot
% which corresponds to the decay time when fitdata is present for all
% selected datapoints. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 
        return
    end

    switch obj.datapicker.ColourchartplottypeDropDown.Value
        case default
            obj.plotdata.rgb = sum(obj.plotdata.spectra_decay, [3 4]); 
        case 'a' 
            obj.plotdata.rgb = cellfun(@coeffvalues, ...
                test.fitdata.fitobjects, 'UniformOutput', false);
            obj.plotdata.rgb = cellfun(@(x)x(1), ...
                obj.plotdata.rgb); 
       case 'b' 
            obj.plotdata.rgb = cellfun(@coeffvalues, ...
                test.fitdata.fitobjects, 'UniformOutput', false);
            obj.plotdata.rgb = cellfun(@(x)x(2), ...
                obj.plotdata.rgb); 
       case 'c' 
            obj.plotdata.rgb = cellfun(@coeffvalues, ...
                test.fitdata.fitobjects, 'UniformOutput', false);
            obj.plotdata.rgb = cellfun(@(x)x(3), ...
                obj.plotdata.rgb); 
       case 'd' 
            obj.plotdata.rgb = cellfun(@coeffvalues, ...
                test.fitdata.fitobjects, 'UniformOutput', false);
            obj.plotdata.rgb = cellfun(@(x)x(3), ...
                obj.plotdata.rgb); 
    end 

end