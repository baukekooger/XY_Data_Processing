function draw_time_limit_lines(obj)
% draw the lines indicating the selected time limit  

    time_start = obj.datapicker.StartTimeSpinner.Value; 
    time_stop = obj.datapicker.StopTimeSpinner.Value; 
    
    index_start = find(obj.plotdata.time_decay == time_start); 
    index_stop = find(obj.plotdata.time_decay == time_stop); 
    
    % do nothing if any of the indexes is outside of the range 
    if isempty(any([index_start, index_stop]))
        return 
    end
    
    % remove the old lines 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))
    % plot the new lines 
    linestart = xline(obj.plotwindow.ax_spectrum, time_start); 
    linestart.Label = 'from here'; 
    linestart.LabelVerticalAlignment = 'middle';
    linestart.LabelHorizontalAlignment = 'right'; 
    
    linestop = xline(obj.plotwindow.ax_spectrum, time_stop); 
    linestop.Label = 'till here'; 
    linestop.LabelVerticalAlignment = 'middle';
    linestop.LabelHorizontalAlignment = 'left'; 
    
    % update the plotwindow legend to discard the values added by these two
    % lines 
    if isempty(obj.plotwindow.ax_spectrum.Legend)
        return
    end
    obj.plotwindow.ax_spectrum.Legend.String = ...
        obj.plotwindow.ax_spectrum.Legend.String(1:end-2); 

end

