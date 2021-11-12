function passed = check_color_limits(obj, src, event)

    % check if min value is lower than max value
    min = obj.datapicker.ColorMinEditField.Value;
    max = obj.datapicker.ColorMaxEditField.Value;
    if min < max
        passed = true; 
        return
    end
    % set edit field to previous value if max lower than min
    if strcmp(src.Tag, 'MinEdit')
        obj.datapicker.ColorMinEditField.Value = event.PreviousValue; 
    elseif strcmp(src.Tag, 'MaxEdit') 
        obj.datapicker.ColorMaxEditField.Value = event.PreviousValue; 
    else
        error(['source tag not equal to starttimespinner or ' ...
            'stoptimespinner'])
    end
    passed = false; 

end

