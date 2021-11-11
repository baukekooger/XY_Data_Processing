function obj = set_spectra_decay(obj)

% - Select the spectra based on the selected excitation wavelength(s) 
%   in the datapicker app.  
% - Set the plotspectra to have the correct timerange selected in the 
%   datapicker app. 
% - Normalize the spectra to the maximum of the new time selection

% If no datapicker is present yet (at initialization), normalize the
% spectra with their full time range to their maximum value. 

if isempty(obj.datapicker)
    obj.plotdata.spectra_decay = obj.digitizer.spectra(:,:,1,:) ./ ...
        max(obj.digitizer.spectra(:,:,1,:), [], 4); 
    obj.plotdata.time_decay = obj.digitizer.time;
    
    obj.fitdata.fitobjects = cell(obj.xystage.ynum, obj.xystage.xnum, 1); 
    obj.fitdata.goodnesses = cell(obj.xystage.ynum, obj.xystage.xnum, 1); 
    obj.fitdata.outputs = cell(obj.xystage.ynum, obj.xystage.xnum, 1);
    return
end


% delete the timerange indication lines 
delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'ConstantLine'))

% compress the data 
compress_data_decay(obj) 
% update the values in the time spinner to new time vector
update_time_spinner(obj) 

% get the selected excitation wavelength(s) 
ex_wls = str2double(obj.datapicker.ExcitationWavelengthListBox.Value);
[~, ex_index, ~] = intersect(obj.laser.excitation_wavelengths, ...
            ex_wls); 

% get the selected time range 
t_start = obj.datapicker.StartTimeSpinner.Value;
t_start_index = find(obj.plotdata.time_decay == t_start); 
t_stop = obj.datapicker.StopTimeSpinner.Value;
t_stop_index = find(obj.plotdata.time_decay == t_stop); 

% select the time range  
obj.plotdata.spectra_decay = obj.plotdata.spectra_decay(:, :, ex_index, ...
    t_start_index:t_stop_index);
obj.plotdata.time_decay = ...
    obj.plotdata.time_decay(t_start_index:t_stop_index);

% compare the mean of the first 10 samples to the maximum of the signal. 
% if this is less than 70% of the average of the 10 highest values, the 
% sample includes time before the pulse and normalization is done with 
% respect to the highest sample 

mean_beginning = mean(obj.plotdata.spectra_decay(:,:,:,1:10), 4); 
max_values = maxk(obj.plotdata.spectra_decay, 10, 4);
mean_maxvalues = mean(max_values, 4); 

if mean_beginning < 0.5*mean_maxvalues
    obj.plotdata.spectra_decay = obj.plotdata.spectra_decay(:, :, ...
        ex_index, t_start_index:t_stop_index) ./ ...
        max(obj.plotdata.spectra_decay, [], 4); 
else
    obj.plotdata.spectra_decay = obj.plotdata.spectra_decay(:, :, ...
        ex_index, :) ./ mean_maxvalues; 
end

end
