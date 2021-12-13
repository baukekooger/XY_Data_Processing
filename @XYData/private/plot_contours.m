function plot_contours(obj)
% Deletes the current contour if existing and plots a new contour based on
% the current settings in the plot settings. 

    % Don't attempt anything if there is no surface plot (less than two
    % measurement points for both x and y) 
    if isempty(findobj(obj.datapicker.UIAxes, 'Type', 'Surface')) || ...
            isempty(findobj(obj.plotwindow.ax_rgb, 'Type', 'Surface'))
        return
    end

    % Delete contours and return if box not checked. 
    if not(obj.datapicker.ContoursCheckBox.Value)
        delete(findobj(obj.datapicker.UIAxes, 'Type', 'Contour')); 
        delete(findobj(obj.plotwindow.ax_rgb, 'Type', 'Contour')); 
        return
    end

    % Get settings.
    levels = obj.datapicker.LevelsSpinner.Value; 
    minvalue = obj.datapicker.ColorMinEditField.Value;
    maxvalue = obj.datapicker.ColorMaxEditField.Value; 

    % Clip the plotting data by the min and max color values such that
    % automatic level making can be used. 
    rgbvalues = flipud(obj.plotdata.rgb); 
    rgbvalues(rgbvalues>maxvalue) = maxvalue; 
    rgbvalues(rgbvalues<minvalue) = minvalue; 

    colorplot = findobj(obj.datapicker.UIAxes, 'Type', 'Surface'); 
    x = colorplot.XData;
    y = colorplot.YData; 

    % Delete any existing contour
    delete(findobj(obj.datapicker.UIAxes, 'Type', 'Contour')); 
    delete(findobj(obj.plotwindow.ax_rgb, 'Type', 'Contour')); 


    % Plot the new contour
    hold(obj.datapicker.UIAxes, 'on')
    [~, co] = contour(obj.datapicker.UIAxes, x, y, ...
        rgbvalues, levels); 
    co.LineColor = 'k';
    co.ShowText = 'on'; 
    co.LevelList = round(co.LevelList, 3, 'significant'); 
    hold(obj.datapicker.UIAxes, 'off')

    hold(obj.plotwindow.ax_rgb, 'on')
    [~, co] = contour(obj.plotwindow.ax_rgb, x, y, ...
        rgbvalues, levels); 
    co.LineColor = 'k';
    co.ShowText = 'on'; 
    co.LevelList = round(co.LevelList, 3, 'significant'); 
    hold(obj.plotwindow.ax_rgb, 'off')
end

