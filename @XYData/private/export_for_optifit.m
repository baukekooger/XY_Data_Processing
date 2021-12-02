function export_for_optifit(obj)
% Export the first selected datapoint in the datacursor. Show a messagebox
% when the cursor is empty or has more datapoints in it, or when the
% incorrect spectra are selected. 

    cursorinfo = obj.datacursor.xy.getCursorInfo; 
    if not(strcmp(obj.datapicker.SpectraDropDown.Value, 'Transmission'))
        uialert(obj.datapicker.UIFigure, ['Spectra not set to ' ...
            'transmission, please select transmission as the ' ...
            'spectra option.'], 'Invalid selection')
        return
    elseif isempty(cursorinfo)
        uialert(obj.datapicker.UIFigure, ['No point selected for ' ...
            'exporting, please select a single point in ' ...
            'the xy datapicker.'], 'Invalid selection')
        return
    elseif length(cursorinfo) > 1
        msg = 'More than one point selected. Only exporting first point.';
        title = 'Multiple points selected';
        selection = uiconfirm(obj.datapicker.UIFigure, msg, title, ...
           'Options', {'Continue', 'Cancel'}, ...
           'DefaultOption', 1, 'CancelOption', 2, 'Icon', 'warning');
        if strcmp(selection, 'Cancel')
            return
        end
        cursorinfo = cursorinfo(end); 
    end
    
    % select and prep data for optifit (takes transmittance in %).
    [~, idx, ~, idy] = get_cursor_position(obj, cursorinfo, 1);
    transmittance = 100.* ...
                    squeeze(obj.plotdata.spectra_transmission(idy, idx,:));
    wls = obj.plotdata.wavelengths_transmission; 

    % get file path for storing the file and write the file 
    dir = uigetdir(pwd, 'Select directory for file');
    filename = erase(obj.fname, '.hdf5'); 
    filename = sprintf('%s\\%s_x%.2d_y%.2d.csv', dir, filename, idx, idy);
    writematrix([wls, transmittance], filename);

end