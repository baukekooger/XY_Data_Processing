function passed = check_time_range_limits(obj, src, event)
% assert that the selected start time is smaller than the stop time, 
% return false otherwise. 

% may be called by spinners from the ui, or by the datacursormode of the
% plotwindow 

% check if source is spinner or datacursor (hggroup)
switch src.Type
    case 'uispinner' 
        passed = check_limits_uispinner(obj, src, event); 
    case 'hggroup' 
        passed = check_limits_datacursor(obj, src, event); 
    otherwise 
        error('source for checking time range limits unknown')
end            
end

function passed = check_limits_uispinner(obj, src, event)
% check if stop value is lower than start value
disp('called function check limits uispinner')
start = obj.datapicker.StartTimeSpinner.Value;
stop = obj.datapicker.StopTimeSpinner.Value;
    if start < stop
        passed = true; 
        return
    end
% set spinner to previous value if stop lower than start
    if strcmp(src.Tag, 'StartTimeSpinner')
        obj.datapicker.StartTimeSpinner.Value = event.PreviousValue; 
    elseif strcmp(src.Tag, 'StopTimeSpinner') 
        obj.datapicker.StopTimeSpinner.Value = event.PreviousValue; 
    else
        error(['source tag not equal to starttimespinner or ' ...
            'stoptimespinner'])
    end
passed = false; 
end


