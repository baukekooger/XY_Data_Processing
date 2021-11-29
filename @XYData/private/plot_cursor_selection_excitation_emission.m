function plot_cursor_selection_excitation_emission(obj)
% Get the number of elements selected from the datacursor, and plot the
% corresponding spectra in the spectrum plot. If the show fits button is
% enabled, check if fit exists and plot if they do. Otherwise give
% notification no fit is available or smth

    % Getting the information about where the user clicked. 
    cursor_info = obj.datacursor.xy.getCursorInfo();
    
    % Flipping the cursorinfo ensures the newest datapoint is treated last 
    % which preserves the markers and colors for previously selected points.  
    cursor_info = flip(cursor_info); 
    if isempty(cursor_info)
        return
    end
    
    
    % If the button for showing fits is enabled, make the fits.  
%     show_fits = obj.datapicker.ShowFitSelectedPointsButton.Value; 
%     if show_fits
%         fit_selected_points(obj, cursor_info);
%     end 
    
    % Delete all lines in the rgb plot and spectrum plot
    delete(findobj([obj.plotwindow.ax_spectrum, obj.plotwindow.ax_rgb], ...
        'Type', 'Line'))
    
    % Load color and marker settings such that always the same order is
    % used when redrawing data. 
    colors_markers = load('colors_markers.mat'); 
    
    % Perform the plot based on which spectrumtype is selected.
    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            plot_spectra_emission(obj, cursor_info, colors_markers)
            plot_position_indicators(obj, cursor_info, colors_markers);
            set_annotation(obj, cursor_info, colors_markers);
        case 'Excitation'
            plot_spectra_excitation(obj, cursor_info, colors_markers)
            plot_position_indicators(obj, cursor_info, colors_markers);
            set_annotation(obj)
    end

end

function plot_spectra_emission(obj, cursor_info, colors_markers) 
% Plot the spectra corresponding to the selected position point. 
    
    hold(obj.plotwindow.ax_spectrum, 'on');

    number_of_markers = 20;
    markerstep = ceil(length(obj.plotdata.wavelengths_emission) / ...
        number_of_markers);

    ex_wls = obj.plotdata.wavelengths_excitation; 
    wavelengths = obj.plotdata.wavelengths_emission; 
    for ii=1:length(cursor_info)
        for jj = 1:length(ex_wls)
            [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
            spectrum = squeeze(obj.plotdata.spectra_emission(...
                idy, idx, jj, :));  
            plot(obj.plotwindow.ax_spectrum, wavelengths, spectrum, ...
                'Color', colors_markers.colors(ii,:), 'Marker', ...
                colors_markers.markers{jj}, 'MarkerIndices', ...
                1:markerstep:length(wavelengths));
        end
    end
    hold(obj.plotwindow.ax_spectrum, 'off');
end

function plot_position_indicators(obj, cursor_info, colors_markers) 
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

% function plot_fits(obj, cursor_info, colors_markers)
% % plot the fits for the selected datapoints. 
%     [ex_wls, ex_index] = get_excitation_wavelengths(obj); 
%     % set current axes cause cfit object takes no axes argument.
%     axes(obj.plotwindow.ax_spectrum)
%     hold on
%     for ii=1:length(cursor_info)
%         [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
%         for jj = 1:length(ex_wls)
%             fitobj = obj.fitdata.fitobjects{idy, idx, ex_index(jj)}; 
%             color = colors_markers.colors(ii,:)*0.7; 
%             marker = colors_markers.markers{jj};
%             fp = plot(fitobj); 
%             fp.Color = color;
%             fp.Marker = marker; 
%             fp.LineWidth = 1.5;
%         end
%     end
%     hold off
% end

function set_annotation(obj, cursor_info, colors_markers)
% Set plot limits based on the type of plot 
    correctiontype = obj.datapicker.CorrectionDropDown.Value; 
    switch correctiontype
        case 'No Correction'
            title(obj.plotwindow.ax_spectrum, ...
                'Spectra without any correction');
        case 'Dark Spectrum'
            title(obj.plotwindow.ax_spectrum, ['Spectra with Dark ' ...
                'Spectrum Removed']);
        case 'Dark Spectrum, Power'
            title(obj.plotwindow.ax_spectrum, ...
                'Spectra corrected for Dark Spectrum and Power');
        case 'Dark Spectrum, Power, Beamsplitter'
            title(obj.plotwindow.ax_spectrum, ...
                ['Spectra corrected for Dark Spectrum, Power' ...
                ' and BeamSplitter']);
    end

    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])
    ylabel(obj.plotwindow.ax_spectrum, 'counts');
    minwl = obj.plotdata.wavelengths_emission(1); 
    maxwl = obj.plotdata.wavelengths_emission(end); 
    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel(obj.plotwindow.ax_spectrum, 'wavelength [nm]'); 
    if length(obj.plotdata.wavelengths_excitation) > 1
        legendcell = make_legendcell_emission(obj, cursor_info, ...
            colors_markers); 
        obj.plotwindow.ax_spectrum.Children = ...
            flip(obj.plotwindow.ax_spectrum.Children);
        legend(obj.plotwindow.ax_spectrum, legendcell);
    end  

end


function legendcell = make_legendcell_emission(obj, cursor_info, ...
    colors_markers)
% Make the legendcell for in the spectrum plot by plotting empty points. 
% This enables setting the legend line color to a neutral color when 
% multiple wavelengths and positions are plotted.
    
    % Flipping the order of the wavelengths because the children of the 
    % plot are also flipped for this legend. 
    ex_wls = flip(obj.plotdata.wavelengths_excitation); 
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



