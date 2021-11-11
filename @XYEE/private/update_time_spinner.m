function update_time_spinner(obj)
% valdi the time spinner values to the closest value in the time vector
% and set the step according to the selected data compression. 

    factor = obj.datapicker.DataCompressionDropDown.Value; 
    
    if factor == "none"
        factor = 1; 
    else
        factor = str2double(factor);
    end
    
    timestep = factor/obj.digitizer.sample_rate; 
    upperlimit = max(obj.plotdata.time_decay); 
    
    tstartcurrent = obj.datapicker.StartTimeSpinner.Value; 
    tstopcurrent = obj.datapicker.StopTimeSpinner.Value; 
    
    tvalidstart = tstartcurrent - rem(tstartcurrent, timestep); 
    tvalidstop = tstopcurrent - rem(tstartcurrent, timestep); 
    if tvalidstop > upperlimit
        tvalidstop = upperlimit; 
    end
    % round values to prevent not matching due to numerical errors. 
    tvalidstart = round(tvalidstart, 10); 
    tvalidstop = round(tvalidstop, 10);

    obj.datapicker.StartTimeSpinner.Value = tvalidstart; 
    obj.datapicker.StartTimeSpinner.Step = timestep; 
    obj.datapicker.StartTimeSpinner.Limits = [0 upperlimit]; 

    obj.datapicker.StopTimeSpinner.Value = tvalidstop; 
    obj.datapicker.StopTimeSpinner.Step = timestep; 
    obj.datapicker.StopTimeSpinner.Limits = [0 upperlimit]; 

end

