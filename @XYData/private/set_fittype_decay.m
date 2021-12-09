function set_fittype_decay(obj)
% set the fitdata.fittype attribute to the corresponding library 
% curve name.
% update the expression shown in the gui. 
% reset the fitdata
    switch obj.datapicker.FitTypeDropDown.Value
        case 'Single Exponential' 
            obj.fitdata.fittype = 'exp1'; 
            obj.datapicker.ExpressionFormula.Interpreter = 'latex';
            obj.datapicker.ExpressionFormula.Text = ...
                '$y = Ce^{\frac{-t}{\tau}}$'; 
            obj.datapicker.ExpressionFormula.FontSize = 20;
        case 'Double Exponential' 
            obj.fitdata.fittype = 'exp2'; 
            obj.datapicker.ExpressionFormula.Interpreter = 'latex'; 
            obj.datapicker.ExpressionFormula.Text = ...
                '$y = C_{1}e^{\frac{-t}{\tau_{1}}} + C_{2}e^{\frac{-t}{\tau_{2}}}'; 
            obj.datapicker.ExpressionFormula.FontSize = 20;
    end
    
end