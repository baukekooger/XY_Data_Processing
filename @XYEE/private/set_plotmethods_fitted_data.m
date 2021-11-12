function set_plotmethods_fitted_data(obj)
% Set all the options for populating the rgb plot with. If the fitdata is
% not fully set, do only the default option and disable this part of the
% ui. 

    default = {'default'};

    if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
        obj.datapicker.ColorChartPlotTypeDropDown.Items = default; 
        obj.datapicker.ColorChartPlotTypeDropDown.Enable = 'off'; 
        return
    end

    coefficients = coeffnames(obj.fitdata.fitobjects{1,1});
    goodness_indicators = fieldnames(obj.fitdata.goodnesses{1,1});
    
    obj.datapicker.ColorChartPlotTypeDropDown.Items = ...
        [default; coefficients; goodness_indicators]; 
    obj.datapicker.ColorChartPlotTypeDropDown.Enable = 'on'; 


end

