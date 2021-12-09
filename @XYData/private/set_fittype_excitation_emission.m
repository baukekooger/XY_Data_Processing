function set_fittype_excitation_emission(obj)
% set the fitdata.fittype attribute to the corresponding library 
% curve name.
    number_of_gaussians = obj.datapicker.FitTypeDropDown.Value; 
    obj.fitdata.fittype = ['gauss' number_of_gaussians]; 
    switch number_of_gaussians
        case '1'
            expression = '$y = ae^{-\left(\frac{\lambda-b}{c}\right)^{2}} $';  
        case {'2', '3', '4', '5', '6', '7', '8'}
            expression = ['$y = \sum_{i=1}^{' number_of_gaussians ...
                '} a_{i}e^{-\left(\frac{\lambda-b_{i}}{c_{i}}\right)' ...
                '^{2}} $'];  
    end
    obj.datapicker.ExpressionFormula.Interpreter = 'latex';
    obj.datapicker.ExpressionFormula.Text = expression;
    obj.datapicker.ExpressionFormula.FontSize = 20;

end