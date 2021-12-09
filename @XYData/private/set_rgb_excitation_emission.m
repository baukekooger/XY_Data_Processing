function obj = set_rgb_excitation_emission(obj)
% Sets the RGB color mapping of the datapicker and plotwindow. The default
% value setting for the rgb values is the integral of the plotdata spectra.
% When fitdata is present, the fitdata can be used for plotting as well. 

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all') 
        switch obj.datapicker.SpectraDropDown.Value
            case 'Emission'
                obj.plotdata.rgb = sum(obj.plotdata.spectra_emission, ...
                    [3 4]); 
            case 'Excitation'
                obj.plotdata.rgb = sum(obj.plotdata.spectra_excitation, ...
                    3); 
            case 'Power'
                obj.plotdata.rgb = sum(obj.plotdata.power_excitation, ...
                    3); 
        end
        return
    end
    
    parameter = obj.datapicker.ColorChartDropDown.Value;
    switch parameter
        case coeffnames(obj.fitdata.fitobjects{1,1,1})
            obj.plotdata.rgb = cellfun(@(x)x.(parameter), ...
                obj.fitdata.fitobjects);
            obj.plotdata.rgb = mean(obj.plotdata.rgb, 3); 
        case fieldnames(obj.fitdata.goodnesses{1,1,1})
            obj.plotdata.rgb = cellfun(@(x)x.(parameter), ...
                obj.fitdata.goodnesses);
            obj.plotdata.rgb = mean(obj.plotdata.rgb, 3); 
    end
end
