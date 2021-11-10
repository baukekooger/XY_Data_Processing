function plot_cursor_selection_decay(obj)
% Get the number of elements selected from the datacursor, and plot the
% corresponding spectra in the spectrum plot. If the show fits button is
% enabled, check if fit exists and make them if not. Add fits in the plot.

    % Getting the information about where the user clicked. 
    cursor_info = obj.datacursor.xy.getCursorInfo();
    
    % Flipping the cursorinfo ensures the newest datapoint is treated last 
    % which preserves the markers and colors for previously selected points.  
    cursor_info = flip(cursor_info); 
    
    % If the button for showing fits is enabled, make the fits.  
    show_fits = obj.datapicker.ShowFitSelectedPointsButton.Value; 
    if show_fits
        fit_selected_points(obj, cursor_info);
    end 
    
    % Delete all lines in the rgb plot and spectrum plot
    delete(findobj([obj.plotwindow.ax_spectrum, obj.plotwindow.ax_rgb], ...
        'Type', 'Line'))
    
    % Load color and marker settings such that always the same order is
    % used when redrawing data. 
    colors_markers = load('colors_markers.mat'); 
    
    % adding a comment
   

    % Perform the plots 
    plot_spectra_decay(obj, cursor_info, colors_markers);
    plot_position_indicators(obj, cursor_info, colors_markers);
    if show_fits
        plot_fits(obj, cursor_info, colors_markers);
        show_fitdata_table(obj, cursor_info)  
    end
    set_spectrum_plot_limits(obj, cursor_info, colors_markers);

end

function obj = fit_selected_points(obj, cursor_info)
% Fit the traces to the set fit type for the selected datapoints. 

    % Get the excitation wavelength index
    [~, ex_index] = get_excitation_wavelengths(obj); 
    % Don't do anything when the cursor has no length 
    if length(cursor_info) < 1
        return 
    end  
    % Get the position index. Check if there is already fit data. 
    % Otherwise perform the fit for that specific index. 
    for ii = 1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii);
        for jj = 1:length(ex_index) 
            if isempty(obj.fitdata.fitobjects{idy, idx, ex_index})
                obj = fit_single_trace_decay(obj, idy, idx, ex_index); 
            end
        end
    end
end



function obj = plot_spectra_decay(obj, cursor_info, colors_markers) 
% plot the spectra corresponding to the selected position point. 
   
    hold(obj.plotwindow.ax_spectrum, 'on');
    [ex_wls, ~] = get_excitation_wavelengths(obj); 
    % define the number of markers that should be present.
    samples_plot = length(obj.plotdata.spectra_decay(1,1,1,:));
    number_of_markers = 20;
    markerstep = ceil(samples_plot / number_of_markers);
    time = obj.plotdata.time_decay; 
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        for jj = 1:length(ex_wls)
            % plot decay traces
            spectrum = squeeze(obj.plotdata.spectra_decay(idy, idx, jj, :));
            % show fitted line if show fits button on.   
            plot(obj.plotwindow.ax_spectrum, time, spectrum, ...
                'Color', colors_markers.colors(ii,:), 'Marker',...
            colors_markers.markers{jj}, 'MarkerIndices', ...
            1:markerstep:samples_plot);
        end
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
    [ex_wls, ex_index] = get_excitation_wavelengths(obj); 
    % set current axes cause cfit object takes no axes argument.
    axes(obj.plotwindow.ax_spectrum)
    hold on
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        for jj = 1:length(ex_wls)
            fitobj = obj.fitdata.fitobjects{idy, idx, ex_index(jj)}; 
            color = colors_markers.colors(ii,:)*0.7; 
            marker = colors_markers.markers{jj};
            fp = plot(fitobj); 
            fp.Color = color;
            fp.Marker = marker; 
            fp.LineWidth = 1.5;
        end
    end
    hold off
end

function set_spectrum_plot_limits(obj, cursor_info, colors_markers)
% set the legend and limit
    legendcell = makelegendcell_decay_spectra(obj, cursor_info, ...
        colors_markers);
    % set axes labels and legends 
    xlabel(obj.plotwindow.ax_spectrum, 'time [s]'); 
    ylabel(obj.plotwindow.ax_spectrum, 'arbitrary unit');
    obj.plotwindow.ax_spectrum.YLim = [0, 1]; 
    tstart = obj.plotdata.time_decay(1); 
    tstop = obj.plotdata.time_decay(end); 
    obj.plotwindow.ax_spectrum.XLim = [tstart, tstop]; 
    titleplot = sprintf('Decay traces using %s over %.0f pulses', ... 
        obj.digitizer.measurement_mode, obj.digitizer.pulses); 
    title(obj.plotwindow.ax_spectrum, titleplot); 
    legend(obj.plotwindow.ax_spectrum, legendcell);
end


function legendcell = makelegendcell_decay_spectra(obj, cursor_info, ...
    colors_markers)
% make the legendcell for in the spectrum plot. 
    [ex_wls, ~] = get_excitation_wavelengths(obj); 
    legendcell = cell(1, length(ex_wls));
    hold(obj.plotwindow.ax_spectrum, 'on');
    for ii = 1:length(ex_wls)
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
    hold(obj.plotwindow.ax_spectrum, 'off');
end






