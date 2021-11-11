function set_plotmethods_fitted_data(obj)
% Set all the options for populating the rgb plot with. 

default = {'default'};
coefficients = coeffnames(obj.fitdata.fitobjects{1,1});
goodness_indicators = fieldnames(obj.fitdata.goodnesses{1,1});

obj.datapicker.ColourchartplottypeDropDown.Items = ...
    [default; coefficients; goodness_indicators]; 
obj.datapicker.ColourchartplottypeDropDown.Enable = 'on'; 


end

