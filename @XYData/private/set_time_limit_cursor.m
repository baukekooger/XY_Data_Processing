function changed =  set_time_limit_cursor(obj)
% Set the time limit for start or stop time by clicking in the spectrum
% plot. The start (or stop) time will only changed if the checkbox for
% click start (or stop) is enabled. 

    % return true if limit changed, false if limit unchanged.  
    changed = false;
    checkstart = obj.datapicker.ClickStartCheckBox.Value; 
    checkstop = obj.datapicker.ClickStopCheckBox.Value;
    % don't do anything if the checkboxes are not enabled. Only one can be
    % enabled at a time. 
    
    if not(any([checkstart, checkstop]))
        return 
    end 
    
    % get the cursor info and remove any tips if there are more than one. 
    cursorinfo = obj.datacursor.plotwindow.getCursorInfo; 
    % if there are multiple cursor tips, the last one if the initial click. 
    cursorinfo = cursorinfo(end); 
    time_selected = cursorinfo.Position(1); 
    % round to 10 ns to prevent not being able to find the data later. 
    time_selected = round(time_selected, 8); 

    if checkstart
        if time_selected >= obj.datapicker.StopTimeSpinner.Value
            return
        end
        obj.datapicker.StartTimeSpinner.Value = time_selected; 
    elseif checkstop
        if time_selected <= obj.datapicker.StartTimeSpinner.Value
            return
        end
        obj.datapicker.StopTimeSpinner.Value = time_selected; 
    else 
        error(['neither check start nor check stop enabled but still ' ...
            'executed set time limit function'])
    end
    changed = true; 

end

