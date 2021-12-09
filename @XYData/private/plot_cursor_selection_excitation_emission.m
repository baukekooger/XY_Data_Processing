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
   
    % Delete all lines in the rgb plot and spectrum plot
    delete(findobj([obj.plotwindow.ax_spectrum, obj.plotwindow.ax_rgb], ...
        'Type', 'Line'))
    
    % Load color and marker settings such that always the same order is
    % used when redrawing data. 
    colors_markers = load('colors_markers.mat'); 
    
    % Perform the plot based on which spectrumtype is selected.
    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            legendcell = make_legendcell_emission(obj, cursor_info, ...
                colors_markers); 
            plot_spectra_emission(obj, cursor_info, colors_markers)
            if obj.datapicker.ShowFitSelectedButton.Value
                fit_selected(obj, cursor_info); 
                plot_fits(obj, cursor_info, colors_markers);
                show_fitdata_table(obj, cursor_info)  
            end
            plot_position_indicators(obj, cursor_info, colors_markers);
            set_annotation(obj, legendcell);
        case 'Excitation'
            plot_spectra_excitation(obj, cursor_info, colors_markers)
            if obj.datapicker.ShowFitSelectedButton.Value
                fit_selected(obj, cursor_info)
                plot_fits(obj, cursor_info, colors_markers)
                show_fitdata_table(obj, cursor_info)  
            end
            plot_position_indicators(obj, cursor_info, colors_markers);
            set_annotation(obj)
        case 'Power' 
            plot_spectra_power(obj, cursor_info, colors_markers)
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

function plot_spectra_excitation(obj, cursor_info, colors_markers)
% Plot the excitation spectra for the selected points in the xy datapicker.

    hold(obj.plotwindow.ax_spectrum, 'on');
    wavelengths = obj.plotdata.wavelengths_excitation; 
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        spectrum = squeeze(obj.plotdata.spectra_excitation(idy, idx, :));  
        plot(obj.plotwindow.ax_spectrum, wavelengths, spectrum, ...
            'Color', colors_markers.colors(ii,:));
    end
    hold(obj.plotwindow.ax_spectrum, 'off');
end

function plot_spectra_power(obj, cursor_info, colors_markers)
% Plot the excitation spectra for the selected points in the xy datapicker.

    hold(obj.plotwindow.ax_spectrum, 'on');
    wavelengths = obj.plotdata.wavelengths_excitation; 
    for ii=1:length(cursor_info)
        [~, idx, ~, idy] = get_cursor_position(obj, cursor_info, ii); 
        spectrum = squeeze(obj.plotdata.power_excitation(idy, idx, :));  
        plot(obj.plotwindow.ax_spectrum, wavelengths, spectrum, ...
            'Color', colors_markers.colors(ii,:));
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

function obj = fit_selected(obj, cursor_info)
% Fit the current spectra
    switch obj.datapicker.SpectraDropDown.Value 
        case 'Emission'
            % Get the selected excitation wavelength index
            [~, ex_index] = get_excitation_wavelengths(obj); 
            % Get the position index. Check if there is already fit data. 
            % Otherwise perform the fit for that specific index. 
            for ii = 1:length(cursor_info)
                [~, idx, ~, idy] = ...
                    get_cursor_position(obj, cursor_info, ii);
                for jj = 1:length(ex_index) 
                    if isempty(...
                            obj.fitdata.fitobjects{idy, idx, jj})
                        obj = ...
                            fit_single_emission(obj, idy, idx, jj); 
                    end
                end
            end
        case 'Excitation'
            for ii = 1:length(cursor_info)
                [~, idx, ~, idy] = ...
                    get_cursor_position(obj, cursor_info, ii);            
                if isempty(...
                        obj.fitdata.fitobjects{idy, idx})
                    obj = ...
                        fit_single_excitation(obj, idy, idx); 
                end
            end
    end
end

function plot_fits(obj, cursor_info, colors_markers)
% plot the fits for the selected datapoints. 
    switch obj.datapicker.SpectraDropDown.Value 
        case 'Emission'
            number_of_markers = 20;
            markerstep = ceil(length(obj.plotdata.wavelengths_emission) / ...
            number_of_markers);

            [ex_wls, ~] = get_excitation_wavelengths(obj); 
            % set current axes cause cfit object takes no axes argument.
            axes(obj.plotwindow.ax_spectrum)
            hold on
            for ii=1:length(cursor_info)
                [~, idx, ~, idy] = get_cursor_position(obj, ...
                    cursor_info, ii); 
                for jj = 1:length(ex_wls)
                    fitobj = obj.fitdata.fitobjects{idy, idx, jj}; 
                    color = colors_markers.colors(ii,:)*0.7; 
                    marker = colors_markers.markers{jj};
                    fp = plot(fitobj); 
                    fp.Color = color;
                    fp.Marker = marker; 
                    fp.LineWidth = 1.5;
                    fp.MarkerIndices = 1:markerstep:...
                        length(fp.XData);
                end
            end
        case 'Excitation'
            axes(obj.plotwindow.ax_spectrum)
            hold on
            for ii=1:length(cursor_info)
                [~, idx, ~, idy] = get_cursor_position(obj, ...
                cursor_info, ii); 
                fitobj = obj.fitdata.fitobjects{idy, idx}; 
                color = colors_markers.colors(ii,:)*0.7; 
                fp = plot(fitobj); 
                fp.Color = color;
                fp.LineWidth = 1.5;
            end
    end
    hold off
end

function set_annotation(obj, varargin)
% Set plot limits based on the type of plot 
    title(obj.plotwindow.ax_spectrum, title_spectrum(obj));
    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])
    ylabel(obj.plotwindow.ax_spectrum, ylabel_spectrum(obj));
    [min_x, max_x] = set_limits_spectrum(obj);
    xlim(obj.plotwindow.ax_spectrum, [min_x, max_x])
    xlabel(obj.plotwindow.ax_spectrum, 'wavelength [nm]'); 
    if length(obj.plotdata.wavelengths_excitation) > 1 ...
            && not(isempty(varargin))
        legendcell = varargin{1}; 
        legend(obj.plotwindow.ax_spectrum, legendcell);
    else
        legend('hide')
    end  
end

function title_spectrum = title_spectrum(obj)
% Determine the title for the spectrum plot based on all the various
% current settings.
    spectratype = obj.datapicker.SpectraDropDown.Value; 
    correctiontype = obj.datapicker.CorrectionDropDown.Value; 
    switch spectratype
        case 'Emission'
            switch correctiontype
                case 'No Correction'
                    title_spectrum = [spectratype ...
                        ' spectra without any correction']; 
                case 'Dark Spectrum'
                    title_spectrum = [spectratype ' Spectra with dark ' ...
                        'spectrum removed'];
                case 'Dark Spectrum, Power'
                    title_spectrum = [spectratype ...
                        ' spectra corrected for dark spectrum and power'];
                case 'Dark Spectrum, Power, Beamsplitter'
                    title_spectrum = [spectratype ...
                        ' spectra corrected for dark spectrum, power' ...
                        ' and Beamsplitter'];
            end  
        case 'Excitation'
            emission_peak = obj.datapicker.EmissionPeakSpinner.Value; 
            peak_width = obj.datapicker.PeakWidthSpinner.Value;
            switch correctiontype
                case 'No Correction'
                    title_spectrum = [spectratype, [' spectra without ' ...
                        'any correction, emissionpeak = '], ...
                        sprintf('%.1f nm, ', emission_peak), ...
                        'peak width = ', sprintf('%.1f nm', peak_width)]; 
                case 'Dark Spectrum'
                    title_spectrum = [spectratype, [' spectra with ' ...
                        'dark spectrum removed, emissionpeak = '], ...
                        sprintf('%.1f nm, ', emission_peak), ...
                        'peak width = ', sprintf('%.1f nm', peak_width)]; 
                case 'Dark Spectrum, Power'
                    title_spectrum = [spectratype, [' spectra corrected ' ...
                        'for dark spectrum and power, emissionpeak = '], ...
                        sprintf('%.1f nm, ', emission_peak), ...
                        'peak width = ', sprintf('%.1f nm', peak_width)]; 
                case 'Dark Spectrum, Power, Beamsplitter'
                    title_spectrum = [spectratype, [' spectra corrected ' ...
                        'for dark spectrum, power and beamsplitter, emissionpeak = '], ...
                        sprintf('%.1f nm, ', emission_peak), ...
                        'peak width = ', sprintf('%.1f nm', peak_width)]; 
            end
        case 'Power'
            switch correctiontype
                case 'Power at Meter'
                    title_spectrum = ['Averaged power measured at ' ...
                        'powermeter'];
                case 'Power at Sample (corrected for beamsplitter)'
                    title_spectrum = ['Averaged power at sample, ' ...
                        'corrected for beamsplitter']; 
                case 'Photon Flux at Meter'
                    title_spectrum = ['Averaged photon flux at ' ...
                        'powermeter']; 
                case 'Photon Flux at Sample (corrected for beamsplitter)'
                    title_spectrum = ['Averaged photon flux at ' ...
                        'powermeter, corrected for beamsplitter']; 
            end
    end
end

function [min_x, max_x] = set_limits_spectrum(obj)
% Set the plotlimits of the x-axis based on the experiment. 
    switch obj.datapicker.SpectraDropDown.Value
        case 'Emission'
            min_x = min(obj.plotdata.wavelengths_emission); 
            max_x = max(obj.plotdata.wavelengths_emission);
        case {'Excitation', 'Power'}
            min_x = min(obj.plotdata.wavelengths_excitation); 
            max_x = max(obj.plotdata.wavelengths_excitation);
    end
end

function label = ylabel_spectrum(obj)
    spectratype = obj.datapicker.SpectraDropDown.Value; 
    correctiontype = obj.datapicker.CorrectionDropDown.Value; 
    switch spectratype
        case {'Emission', 'Excitation'}
            label = 'counts'; 
        case 'Power'
            if contains(correctiontype, 'Photon')
                label = 'photon flux [photons/s]'; 
            else
                label = 'power [W]'; 
            end
    end
end


function legendcell = make_legendcell_emission(obj, cursor_info, ...
    colors_markers)
% Make the legendcell for in the spectrum plot by plotting empty points. 
% This enables setting the legend line color to a neutral color when 
% multiple wavelengths and positions are plotted.
    
    ex_wls = obj.plotdata.wavelengths_excitation; 
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



