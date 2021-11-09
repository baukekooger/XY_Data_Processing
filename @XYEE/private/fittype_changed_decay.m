function fittype_changed_decay(obj)
% set the fitdata.fittype attribute to the corresponding library 
% curve name.
% update the expression shown in the gui. 
% reset the fitdata
    switch obj.datapicker.FitTypeDropDown.Value
        case 'Single Exponential' 
            obj.fitdata.fittype = 'exp1'; 
            obj.datapicker.ExpressionFormula.Interpreter = 'latex';
            obj.datapicker.ExpressionFormula.Text = '$y = a^{bt}$'; 
        case 'Double Exponential' 
            obj.fitdata.fittype = 'exp2'; 
            obj.datapicker.ExpressionFormula.Interpreter = 'latex'; 
            obj.datapicker.ExpressionFormula.Text = ...
                '$y = a^{bt} + c^{dt}'; 
    end
    
    reset_fitdata(obj); 
    plot_cursor_selection_decay(obj)

end