function plot_cursor_selection_decay(obj)
% get the number of elements selected in the datacursor, and plot the
% corresponding spectra in the spectrum plot. 

cursor_info = obj.datacursor.xy.getCursorInfo();

% Delete all lines in the rgb plot and spectrum plot

delete(findobj([obj.plotwindow.ax_spectrum, obj.plotwindow.ax_rgb], ...
    'Type', 'Line'))
hold(obj.plotwindow.ax_spectrum, 'on');
hold(obj.plotwindow.ax_rgb, 'on');

% Load color and marker settings such that always the same order is
% used when redrawing data. 
colors_markers = load(['C:\Users\bauke\Repositories\' ...
    'XYEE_Data_Processing\colors_markers.mat']); 

% Get the selected excitation wavelength(s) for the legend.

ex_wls = str2double(obj.datapicker.ExcitationWavelengthListBox.Value);
[~, ex_index, ~] = intersect(obj.laser.excitation_wavelengths, ...
            ex_wls); 

% Make empty plots with the correct marker type such that 
% a neutral color is shown in the legend when multiple 
% wavelengths are selected. 

legendcell = cell(1, length(ex_wls));
for ii = 1:length(ex_index)
    if length(cursor_info) > 1
        plot(obj.plotwindow.ax_spectrum, nan, nan, 'Marker',...
            colors_markers.markers{ii}, 'Color', 'k')
        legendcell{ii} = sprintf('%.1f nm', ex_wls(ii)); 
    else
        plot(obj.plotwindow.ax_spectrum, nan, nan, 'Marker', ...
            colors_markers.markers{ii}, ...
            'Color', colors_markers.colors(1,:))
        legendcell{ii} = sprintf('%.1f nm', ex_wls(ii)); 
    end
end

% Plot the actual decay traces 

% define the number of markers that should be present.
samples_plot = length(obj.plotdata.spectra_decay(1,1,1,:));
number_of_markers = 20;
markerstep = ceil(samples_plot / number_of_markers);

time = obj.plotdata.time_decay; 
for ii=1:length(cursor_info)
    [x, idx, y, idy] = get_cursor_position(obj, cursor_info, ii); 
    for jj = 1:length(ex_wls)
        % plot decay traces
        spectrum = squeeze(obj.plotdata.spectra_decay(idy, idx, jj, :));
        plot(obj.plotwindow.ax_spectrum, time, spectrum, 'Color', ...
        colors_markers.colors(ii,:), 'Marker',...
        colors_markers.markers{jj}, 'MarkerIndices', ...
        1:markerstep:samples_plot);

        % plot corresponding circles 
        plot(obj.plotwindow.ax_rgb, x, y, 'o', 'color', ...
        colors_markers.colors(ii,:) * 0.8, ...
        'markersize', 5);
        plot(obj.plotwindow.ax_rgb, x, y, 'o', 'color', 'k',...
        'markerfacecolor', colors_markers.colors(ii, :),...
        'markersize', 5);
    end
end

% set axes labels and legends 
xlabel(obj.plotwindow.ax_spectrum, 'time [s]'); 
ylabel(obj.plotwindow.ax_spectrum, 'arbitrary unit');
titleplot = sprintf('Decay traces using %s over %.0f pulses', ... 
    obj.digitizer.measurement_mode, obj.digitizer.pulses); 
title(obj.plotwindow.ax_spectrum, titleplot); 
legend(obj.plotwindow.ax_spectrum, legendcell);
hold(obj.plotwindow.ax_rgb, 'off');
hold(obj.plotwindow.ax_spectrum, 'off');

% here the fitted data would be plotted. 

if isempty(obj.fitdata)
    return
end

function [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index)
% finds the index of the x and y position value. 
x = cursor_info(index).Position(1); 
y = cursor_info(index).Position(2); 

x_all = unique(obj.plotdata.xy_coordinates(:,:,1)); 
y_all = unique(obj.plotdata.xy_coordinates(:,:,2)); 
% flipping of the y data is necessary b
y_all = flip(y_all); 

idx = find(x_all == x);
idy = find(y_all == y);


end
end










