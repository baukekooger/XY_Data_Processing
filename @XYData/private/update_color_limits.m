function update_color_limits(obj)
% set the new limits for the colour range in the colour plot. 

min = obj.datapicker.ColorMinEditField.Value; 
max = obj.datapicker.ColorMaxEditField.Value; 

caxis(obj.datapicker.UIAxes, [min max]); 

end

