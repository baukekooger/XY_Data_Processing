function set_plotmethods_fitted_data(obj)
% Set all the options for populating the rgb plot with. If the fitdata is
% not fully set, do only the default option and disable this part of the
% ui. 

    default = {'default'};

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.datapicker.ColorChartDropDown.Items = default; 
        obj.datapicker.ColorChartDropDown.Enable = 'off'; 
        return
    end

    switch obj.experiment
        case 'transmission'
            coefficients = coeffnames(obj.fitdata.fitobjects{1,1}); 
            goodness_indicators = fieldnames(obj.fitdata.goodnesses{1,1});
            obj.datapicker.ColorChartDropDown.Items = ...
                ['default'; 'thickness'; 'refractive index (589 nm)'; ...
                coefficients(1:7); goodness_indicators];
            obj.datapicker.ColorChartDropDown.Enable = 'on'; 
        case 'excitation_emission'
            coefficients = coeffnames(obj.fitdata.fitobjects{1,1,1}); 
            goodness_indicators = fieldnames(obj.fitdata.goodnesses{1,1});
            
            obj.datapicker.ColorChartDropDown.Items = ...
                [default; coefficients; goodness_indicators]; 
            obj.datapicker.ColorChartDropDown.Enable = 'on'; 
                
        case 'decay'
            switch obj.datapicker.FitTypeDropDown.Value
                case 'Single Exponential'
                    coefficients = {'C'; 'tau'};
                case 'Double Exponential' 
                    coefficients = {'C1'; 'C2'; 'tau_1'; 'tau_2'}; 
            end
            goodness_indicators = fieldnames(obj.fitdata.goodnesses{1,1});
            
            obj.datapicker.ColorChartDropDown.Items = ...
                [default; coefficients; goodness_indicators]; 
            obj.datapicker.ColorChartDropDown.Enable = 'on'; 
    end
end

