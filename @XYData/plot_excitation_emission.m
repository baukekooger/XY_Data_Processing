function obj = plot_excitation_emission(obj)

% creates an instance of the rgb data picker ui and a dedicated plotwindow

obj.datapicker = picker_excitation_emission;
obj.plotwindow = figure();
spectrum_plot = subplot(1,5, [1 4]);
rgb_plot = subplot(1,5,5);

% Set the ui datadropdown values to the correct wavelengths
excitation_wl = cellstr(string(obj.laser.excitation_wavelengths));
obj.datapicker.EmissionExcitationWavelengthsListBox.Items = excitation_wl;
emission_wl = cellstr(string(obj.spectrometer.wavelengths));
obj.datapicker.ExcitationEmissionWavelengthsListBox.Items = emission_wl;

% Connect ui activity to update functions
obj.datapicker.SpectraCorrectionDropDown.ValueChangedFcn = ...
    @update_spectra;
obj.datapicker.PlottypeDropDown.ValueChangedFcn = @update_plottype;
obj.datapicker.EmissionExcitationWavelengthsListBox.ValueChangedFcn = ...
    @update_plots;
obj.datapicker.ExcitationEmissionWavelengthsListBox.ValueChangedFcn = ...
    @update_plots;
obj.datacursor = datacursormode(obj.datapicker.UIFigure);
obj.datacursor.Enable = 'on';
set(obj.datacursor, 'UpdateFcn', @cursor_clicked);

x = unique(obj.xystage.coordinates(:,:,1));
y = unique(obj.xystage.coordinates(:,:,2));
x = x-min(x); 
y = y-min(y); 

% Define the callback functions or sequences of callback functions
    function update_spectra(~, event)
        obj = set_spectra_excitation_emission(obj, event.Value);
        obj = set_rgb_excitation_emission(obj);
        obj = plot_rgb_excitation_emission(obj);
        plot_cursor_selection
    end

    function update_plottype(varargin)
        if length(varargin) > 1
            event = varargin{2}; 
            plottype = event.Value; 
        else
            plottype = obj.datapicker.PlottypeDropDown.Value; 
        end
    
        switch plottype
            case 'Emission'
                obj.datapicker.EmissionExcitationWavelengthsListBox.Enable = 'On'; 
                obj.datapicker.ExcitationEmissionWavelengthsListBox.Enable = 'Off';
                update_plots
            case 'Excitation' 
                obj.datapicker.EmissionExcitationWavelengthsListBox.Enable = 'Off'; 
                obj.datapicker.ExcitationEmissionWavelengthsListBox.Enable = 'On';
                update_plots
            case 'Power' 
                obj.datapicker.EmissionExcitationWavelengthsListBox.Enable = 'Off'; 
                obj.datapicker.ExcitationEmissionWavelengthsListBox.Enable = 'Off';
                obj.datapicker.SpectraCorrectionDropDown.Enable = 'Off'; 
                update_plots
            case 'Beamsplitter Calibration' 
                obj.datapicker.EmissionExcitationWavelengthsListBox.Enable = 'Off'; 
                obj.datapicker.ExcitationEmissionWavelengthsListBox.Enable = 'Off';
                obj.datapicker.SpectraCorrectionDropDown.Enable = 'Off'; 
                plot_beamsplitter  
        end


    end

    function update_plots(varargin)
        obj = set_rgb_excitation_emission(obj);
        obj = plot_rgb_excitation_emission(obj);
        plot_cursor_selection
    end

    function obj = plot_rgb_excitation_emission(obj)
        % plots the current rgb values in both the picker and the rgb plot
        imagesc(obj.datapicker.UIAxes, obj.plotdata.rgb)
        imagesc(rgb_plot, x, y, obj.plotdata.rgb)
        axis image
    end

    function cursortext = cursor_clicked(~, ~)
        cursor_info = flip(obj.datacursor.getCursorInfo());
        position = cursor_info(end).Position;
        xpos = position(1); ypos = position(2);
        cursortext = sprintf('X = %d, Y = %d', xpos, ypos);
        plot_cursor_selection
    end

    function plot_cursor_selection()
        ex_wls = str2double(...
            obj.datapicker.EmissionExcitationWavelengthsListBox.Value);
        [~, ex_index, ~] = intersect(obj.laser.excitation_wavelengths, ...
            ex_wls); 
        cursor_info = flip(obj.datacursor.getCursorInfo());
        % Delete all lines in the rgb plot and spectrum plot
        delete(findobj([spectrum_plot, rgb_plot], 'Type', 'Line'))
        hold(spectrum_plot, 'on');
        hold(rgb_plot, 'on');
        % Load color and marker settings such that always the same order is
        % used when redrawing data. 
        colors_markers = load('C:\Users\bauke\Repositories\XYEE_Data_Processing\colors_markers.mat'); 
       
        switch obj.datapicker.PlottypeDropDown.Value
            case 'Emission'
                % Make empty plots with the correct marker type such that 
                % a neutral color is shown in the legend when multiple 
                % wavelengths are selected for emission. 
                legendcell = cell(1, length(ex_wls));
                for ii = 1:length(ex_index)
                    if length(cursor_info) > 1
                        plot(spectrum_plot, nan, nan, 'Marker',...
                            colors_markers.markers{ii}, 'Color', 'k')
                        legendcell{ii} = sprintf('%.1f nm', ex_wls(ii)); 
                    else
                        plot(spectrum_plot, nan, nan, 'Marker', ...
                            colors_markers.markers{ii}, ...
                            'Color', colors_markers.colors(1,:))
                        legendcell{ii} = sprintf('%.1f nm', ex_wls(ii)); 
                    end
                end

                for ii=1:length(cursor_info)
                    position = cursor_info(ii).Position;
                    for jj = 1:length(ex_wls)
                        plot(spectrum_plot, obj.spectrometer.wavelengths, ...
                        squeeze(obj.plotdata.spectra_emission(position(2), ...
                        position(1), ex_index(jj), :)), 'Color', ...
                        colors_markers.colors(ii,:), 'Marker',...
                        colors_markers.markers{jj}, 'MarkerIndices', ...
                        1:20:length(obj.spectrometer.wavelengths));

                        xd = x(position(2)); yd = y(position(1)); 
                        plot(rgb_plot, yd, xd, 'o', 'color', ...
                        colors_markers.colors(ii,:) * 0.8, ...
                        'markersize', 5);
                        plot(rgb_plot, yd, xd, 'o', 'color', 'k',...
                        'markerfacecolor', colors_markers.colors(ii, :),...
                        'markersize', 5);
                    end
                end

                xlabel(spectrum_plot, 'Emission Wavelength [nm]'); 
                ylabel(spectrum_plot, 'Counts');
                title(spectrum_plot, ...
                    ['XY Emission Spectra, Sample = ' obj.sample]); 
                legend(spectrum_plot, legendcell);
          
            case 'Excitation'  
                for ii=1:length(cursor_info)
                    position = cursor_info(ii).Position;
                    plot(spectrum_plot,...
                        obj.laser.excitation_wavelengths, ...
                        squeeze(obj.plotdata.spectra_excitation(position(2), ...
                        position(1), :)), 'Color', ...
                        colors_markers.colors(ii,:));     

                    xd = x(position(2)); yd = y(position(1)); 
                    plot(rgb_plot, yd, xd, 'o', 'color', ...
                    colors_markers.colors(ii,:) * 0.8, ...
                    'markersize', 5);
                    plot(rgb_plot, yd, xd, 'o', 'color', 'k',...
                    'markerfacecolor', colors_markers.colors(ii, :),...
                    'markersize', 5);
                end
                
                xlabel(spectrum_plot, 'Excitation Wavelength [nm]'); 
                ylabel(spectrum_plot, 'Counts'); 
                title(spectrum_plot, ...
                    ['XY Excitation Spectra, Sample = ' obj.sample]);
                % no legend needed for excitation plot
                legend(spectrum_plot, 'off');
               
            case 'Power'
                obj = beamsplitter(obj); 

    
        end
        hold(rgb_plot, 'off');
        hold(spectrum_plot, 'off');
    end
       
end



