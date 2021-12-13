function plot_grid(obj)
% Set the colour of the grid of the colour surface. When set to interp, the
% grid appears invisible. 

    % Don't attempt anything if there is no surface plot (less than two
    % measurement points for both x and y) 
    if isempty(findobj(obj.datapicker.UIAxes, 'Type', 'Surface')) || ...
            isempty(findobj(obj.plotwindow.ax_rgb, 'Type', 'Surface'))
        return
    end

    surface_xy = findobj(obj.datapicker.UIAxes, 'Type', 'Surface'); 
    surface_rgb = findobj(obj.plotwindow.ax_rgb, 'Type', 'Surface');
    if obj.datapicker.GridCheckBox.Value
        surface_xy.EdgeColor = 'k'; 
        surface_rgb.EdgeColor = 'k'; 
    else
        surface_xy.EdgeColor = 'interp';
        surface_rgb.EdgeColor = 'interp'; 
    end 
end

