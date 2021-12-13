function  plot_colorbar(obj)
% Plot the colorbar in the datapicker and plotwindow if the checkbox 
% is enabled. 
% Delete the colorbar if checkbox not enabled. 

    % Don't attempt anything if there is no surface plot (less than two
    % measurement points for both x and y) 
    if isempty(findobj(obj.datapicker.UIAxes, 'Type', 'Surface')) || ...
            isempty(findobj(obj.plotwindow.ax_rgb, 'Type', 'Surface'))
        return
    end

    if not(obj.datapicker.ColorBarCheckBox.Value)
        colorbar(obj.datapicker.UIAxes, 'off'); 
        colorbar(obj.plotwindow.ax_rgb, 'off'); 
        return
    end
    
    % plot the colorbar
    colorbar(obj.datapicker.UIAxes); 
    colorbar(obj.plotwindow.ax_rgb); 


end

