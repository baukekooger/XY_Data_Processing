function change_scale_y_axis(obj, event)
% change the scale of the y axis. 

switch event.Value
    case 'Linear'
        obj.plotwindow.ax_spectrum.YScale = 'linear'; 
    case 'Logarithmic'
        obj.plotwindow.ax_spectrum.YScale = 'log'; 
end

