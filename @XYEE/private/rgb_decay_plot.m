function rgb_decay_plot(obj) 
% plot the rgb values on the datapicker window. and the plotwindow if the 
% plotwindow has the plot enabled. 

disp('rgb plot function called')
%% read the spacing values and set xy positions for plotting 
spacing_left = 5; % temporary spacing between the film and the points. 
spacing_bottom = 3; 
sample_width = 51; 
sample_height = 51; 

x = squeeze(obj.xystage.coordinates(:,:,1)); 
x = x - min(x, [], 'all');
x = x + spacing_left; 

y = squeeze(obj.xystage.coordinates(:,:,2)); 
y = y - min(y, [], 'all'); 
y = y + spacing_bottom; 

obj.plotdata.xy_coordinates = cat(3, x, y); 

%% plot the xy chart on the datapicker window

% hold the axes on for the different plots
hold(obj.datapicker.UIAxes, 'on')

% plot the outline of the sample
rectangle(obj.datapicker.UIAxes, 'Position', ...
    [0 0 sample_width sample_height], ...
    'FaceColor', [0.8431, 0.9451, 0.9804]);
% plot the colorchart. flipping the data is necessary for correct display
colorsurface = pcolor(obj.datapicker.UIAxes, x, y, flipud(obj.plotdata.rgb));
colorsurface.FaceColor = 'interp';
% plot the actual measurement points
plot(obj.datapicker.UIAxes, x, y, 'o', 'MarkerFaceColor', ...
    'w', 'MarkerEdgeColor','k'); 
obj.datapicker.UIAxes.XTick = [0; unique(x); sample_width]; 
obj.datapicker.UIAxes.YTick =  [0; unique(y); sample_height];
obj.datapicker.UIAxes.XLim =  [0 sample_width];
obj.datapicker.UIAxes.YLim =  [0 sample_height]; 
xtickformat(obj.datapicker.UIAxes, '%.1f')
ytickformat(obj.datapicker.UIAxes, '%.1f')
axis image
hold(obj.datapicker.UIAxes, 'off')

%% plot the xy chart on the plotwindow indicator if available. 
if isempty(obj.plotwindow.ax_rgb)
    return 
end

hold(obj.plotwindow.ax_rgb, 'on')

rectangle(obj.plotwindow.ax_rgb, 'Position', ...
    [0 0 sample_width sample_height], ...
    'FaceColor', [0.8431, 0.9451, 0.9804]);
% plot the colorchart. flipping the data is necessary for correct display
colorsurface = pcolor(obj.plotwindow.ax_rgb, x, y, ...
    flipud(obj.plotdata.rgb));
colorsurface.FaceColor = 'interp';
axis image

hold(obj.plotwindow.ax_rgb, 'off')

end

