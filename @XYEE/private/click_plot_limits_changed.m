function click_plot_limits_changed(obj, src, ~)
% Check if not both checkboxes for clicking time range limit are enabled.
% If they are both enabled, disable the one that has not been called. 

% disp('calling check limits function')

checkstart = obj.datapicker.ClickStartCheckBox.Value;
checkstop = obj.datapicker.ClickStopCheckBox.Value; 

if not(all([checkstart, checkstop])) 
    return
end

if src == obj.datapicker.ClickStartCheckBox
    obj.datapicker.ClickStopCheckBox.Value = 0;
elseif src == obj.datapicker.ClickStopCheckBox
    obj.datapicker.ClickStartCheckBox.Value = 0; 
else
    error(['Checkbox source does not correspond to checkbox objects' ...
        ' in function - check naming'])
end

