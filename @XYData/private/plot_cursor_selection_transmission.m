function plot_cursor_selection_transmission(obj)
% Get the number of elements selected from the datacursor, and plot the
% corresponding spectra in the spectrum plot. If the show fits button is
% enabled, check if fit exists and plot if they do. Otherwise give
% notification no fit is available or smth

    % Getting the information about where the user clicked. 
    cursor_info = obj.datacursor.xy.getCursorInfo();
    
    % Flipping the cursorinfo ensures the newest datapoint is treated last 
    % which preserves the markers and colors for previously selected points.  
    cursor_info = flip(cursor_info); 
    
    % Delete all lines in the rgb plot and spectrum plot
    delete(findobj([obj.plotwindow.ax_spectrum, obj.plotwindow.ax_rgb], ...
        'Type', 'Line'))
    
    % Load color and marker settings such that always the same order is
    % used when redrawing data. 
    colors_markers = load('colors_markers.mat'); 
    
    % Perform the plots 
    plot_spectra_transmission(obj, cursor_info, colors_markers);
    plot_position_indicators(obj, cursor_info, colors_markers);
    if obj.datapicker.ShowFitsButton.Value
        plot_fits(obj, cursor_info, colors_markers);
        show_fitdata_table(obj, cursor_info)  
    end
    set_spectrum_plot_limits(obj);

end

function obj = plot_spectra_transmission(obj, cursor_info, colors_markers) 
% plot the spectra corresponding to the selected position point. 
   
    hold(obj.plotwindow.ax_spectrum, 'on');
    wavelengths = obj.plotdata.wavelengths_transmission; 
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        spectrum = squeeze(obj.plotdata.spectra_transmission(idy, idx, :));  
        plot(obj.plotwindow.ax_spectrum, wavelengths, spectrum, ...
            'Color', colors_markers.colors(ii,:));
    end
    hold(obj.plotwindow.ax_spectrum, 'off');
end

function obj = plot_position_indicators(obj, cursor_info, colors_markers) 
% plot the colored circles in the rgb plot axes to indicate the position of
% the spectra with respect to the film 
    hold(obj.plotwindow.ax_rgb, 'on');
    for ii=1:length(cursor_info)
        [x, ~, y, ~] = get_cursor_position(obj, cursor_info, ii); 
        % plot corresponding circles 
        plot(obj.plotwindow.ax_rgb, x, y, 'o', 'color', ...
        colors_markers.colors(ii,:) * 0.8, ...
        'markersize', 5);
        plot(obj.plotwindow.ax_rgb, x, y, 'o', 'color', 'k',...
        'markerfacecolor', colors_markers.colors(ii, :),...
        'markersize', 5);
    end
    hold(obj.plotwindow.ax_rgb, 'off');
end

function obj = plot_fits(obj, cursor_info, colors_markers)
% plot the fits for the selected datapoints. 
    % set current axes cause cfit object takes no axes argument.
    axes(obj.plotwindow.ax_spectrum)
    hold on
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        fitobj = obj.fitdata.fitobjects{idy, idx}; 
        color = colors_markers.colors(ii,:)*0.7; 
        fp = plot(fitobj); 
        fp.Color = color;
        fp.LineWidth = 1.5;
    end
    legend("hide")
    hold off
end

function set_spectrum_plot_limits(obj)
% set the legend and plot limits based on the type of plot 
    spectrumtype = obj.datapicker.SpectraDropDown.Value; 
    switch spectrumtype
        case 'Raw Data'
            ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf]);
            ylabel(obj.plotwindow.ax_spectrum, 'counts');
            title(obj.plotwindow.ax_spectrum, 'Raw Spectra');
        case 'Dark Removed'
            ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf]);
            ylabel(obj.plotwindow.ax_spectrum, 'counts');
            title(obj.plotwindow.ax_spectrum, ['Spectra with Dark ' ...
                'Spectrum Removed']);
        case 'Transmission'
            ylim(obj.plotwindow.ax_spectrum, [0 1])
            ylabel(obj.plotwindow.ax_spectrum, 'transmittance');
            title(obj.plotwindow.ax_spectrum, 'Transmission Spectra');
    end
    minwl = obj.plotdata.wavelengths_transmission(1); 
    maxwl = obj.plotdata.wavelengths_transmission(end); 
    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel(obj.plotwindow.ax_spectrum, 'wavelength [nm]'); 
end







