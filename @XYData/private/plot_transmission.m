function plot_transmission(obj)
% Create an instance of the transmission datapicker and plotwindow.
% Provide some intial setup of ui elements such as populating tables and
% comboboxes with the right data. 
% Connect ui element interaction callbacks to different data and plotting 
% operations. 

    obj.datapicker = picker_transmission;
    obj.plotwindow.figure = figure();
    % initialize plotwindow with spectrum axes and rgb axes, this can be 
    % modified in the ui by the user 
    obj.plotwindow.ax_spectrum = subplot(1,5, [1 4]);
    obj.plotwindow.ax_rgb = subplot(1,5,5);
    
    %% initialize the ui components
    min_wl = obj.spectrometer.wavelengths(1); 
    max_wl = obj.spectrometer.wavelengths(end); 
    step = mean(diff(obj.spectrometer.wavelengths)); 
    
    obj.datapicker.MinWavelengthSpinner.Limits = [min_wl, max_wl]; 
    obj.datapicker.MinWavelengthSpinner.Step = step; 
    obj.datapicker.MinWavelengthSpinner.Value = min_wl; 
    
    obj.datapicker.MaxWavelengthSpinner.Limits = [min_wl, max_wl]; 
    obj.datapicker.MaxWavelengthSpinner.Step = step; 
    obj.datapicker.MaxWavelengthSpinner.Value = max_wl;  
    
    % set the default color chart option and disable the dropdown.
    obj.datapicker.ColorChartDropDown.Items = {'default'}; 
    obj.datapicker.ColorChartDropDown.Enable = 'off'; 

    %% initialize and connect data cursors
    obj.datacursor.xy = datacursormode(obj.datapicker.UIFigure);
    obj.datacursor.xy.Enable = 'on';
    obj.datacursor.xy.UpdateFcn = ...
        @(src, event)wrapper_cursor_clicked_xy(event, obj);
    obj.datacursor.plotwindow = datacursormode(obj.plotwindow.figure); 
    obj.datacursor.plotwindow.Enable = 'on'; 
    obj.datacursor.plotwindow.UpdateFcn = ...
        @(src, event)wrapper_cursor_clicked_plotwindow(event, obj);

    %% connect ui elements 
    obj.datapicker.SpectraDropDown.ValueChangedFcn = ...
        @(src, event)wrapper_spectra_type_changed(obj);
    obj.datapicker.PlotDarkSpectrumButton.ButtonPushedFcn = ...
        @(src, event)plot_darkspectrum(obj); 
    obj.datapicker.PlotLampSpectrumButton.ButtonPushedFcn = ...
        @(src, event)plot_lampspectrum(obj); 
    obj.datapicker.MinWavelengthSpinner.ValueChangedFcn = ...
        @(src, event)wavelength_range_changed_spinner(obj, src, event); 
    obj.datapicker.MaxWavelengthSpinner.ValueChangedFcn = ...
        @(src, event)wavelength_range_changed_spinner(obj, src, event); 
    obj.datapicker.ClickMinWavelengthCheckBox.ValueChangedFcn = ...
        @(src, event)assert_checkboxes_wavelength(obj, src); 
    obj.datapicker.ClickMaxWavelengthCheckBox.ValueChangedFcn = ...
        @(src, event)assert_checkboxes_wavelength(obj, src); 
    obj.datapicker.SetRangeButton.ButtonPushedFcn = ...
        @(src, event)set_wavelength_range(obj); 
    obj.datapicker.ResetRangeButton.ButtonPushedFcn = ...
        @(src, event)reset_wavelength_range(obj); 
    obj.datapicker.OptifitManualButton.ButtonPushedFcn = ...
        @(src, event)winopen('Optifit_Manual.pdf'); 
    obj.datapicker.ExportforOptifitButton.ButtonPushedFcn = ...
        @(src, event)export_for_optifit(obj); 
    obj.datapicker.ColorMinEditField.ValueChangedFcn = ...
        @(src, event)color_limits_changed(obj, src, event); 
    obj.datapicker.ColorMaxEditField.ValueChangedFcn = ...
        @(src, event)color_limits_changed(obj, src, event); 
    obj.datapicker.ResetLimitsButton.ButtonPushedFcn = ...
        @(src, event)plot_rgb_transmission(obj); 
    obj.datapicker.ImportOptifitDataButton.ButtonPushedFcn = ...
        @(src, event)read_optifit_data(obj); 
    obj.datapicker.FitSinglePointButton.ButtonPushedFcn = ...
        @(src, event)fit_single_point(obj);
    obj.datapicker.FitAllButton.ButtonPushedFcn = ...
        @(src, event)fit_all_button_pushed(obj); 
    obj.datapicker.ShowFitsButton.ValueChangedFcn = ... 
        @(src, event)show_fit_button_pushed(obj); 
    obj.datapicker.ColorChartDropDown.ValueChangedFcn = ...
        @(src, event)changed_plottype_rgb(obj); 



    %% call the plot rgb function to plot an initial XY color chart 
    set_rgb_transmission(obj);
    plot_rgb_transmission(obj);
    set_plotmethods_fitted_data(obj);
    
    %% define sequenced callbacks

    function cursortext_xy =  wrapper_cursor_clicked_xy(event, obj)
        x = event.Position(1);
        y = event.Position(2); 
        cursortext_xy = sprintf('X = %.1f, Y = %.1f', x, y); 
        plot_cursor_selection_transmission(obj);
    end

    function cursortext_plotwindow = ...
        wrapper_cursor_clicked_plotwindow(event, obj) 
        % Set the datatip value and set the wavelength of corresponding
        % spinner if check is passed. 
        wl = event.Position(1);
        if not(check_range_wavelength_cursor(obj))
            cursortext_plotwindow = ['Minimum wavelength should be ' ...
                'smaller than maximum wavelength']; 
            return
        end
        cursortext_plotwindow = sprintf('wavelength = %.2f', wl); 
        select_nearest_wavelength(obj)
        draw_lines_wavelength_range(obj);
        
    end

    function wavelength_range_changed_spinner(obj, src, event)
        if not(check_range_spinner(obj, src, event))
            return
        end
        select_nearest_wavelength(obj) 
        draw_lines_wavelength_range(obj)
    end

    function wrapper_spectra_type_changed(obj)
        set_spectra_transmission(obj);
        set_rgb_transmission(obj);
        plot_rgb_transmission(obj);
        plot_cursor_selection_transmission(obj);
    end

    function set_wavelength_range(obj)
        set_spectra_transmission(obj); 
        set_rgb_transmission(obj); 
        plot_rgb_transmission(obj); 
        plot_cursor_selection_transmission(obj); 
    end

    function reset_wavelength_range(obj)
        reset_wavelengths(obj)
        set_wavelength_range(obj) 
    end

    function color_limits_changed(obj, src, event)
        % check if the min limit is not higher than the max limit
        if not(check_color_limits(obj, src, event))
            return
        end  
        update_color_limits(obj) 
    end

    function fit_single_point(obj)
        % Fit the point corresponding to the exported point for fitting in
        % optifit, with the optifit fit data. Check if optifit data is
        % present and if not already fitted. 
        if isempty(obj.fitdata.optifit_data)
            if not(request_user_optifit_data(obj))
                return
            end
        elseif not(all(cellfun(@isempty, obj.fitdata.fitobjects), 'all'))
            if not(request_user_refit_singlefit)
                return
            end
        end
        fit_transmission_single_point(obj)
    end

    function fit_all_button_pushed(obj)
        % fit all the points on the film starting from the optifit seed
        % fit. disable the gui while doing so. 
        enable_gui(obj, 'off') 
        if not(strcmp(obj.datapicker.SpectraDropDown.Value, ...
                'Transmission'))
            uialert(obj.datapicker.UIFigure, ['Cannot fit data with ' ...
                'selected spectra type. Please set spectra ' ...
                'to Transmission.'], 'Wrong spectra selected', ...
                'Icon', 'Error')
            enable_gui(obj, 'on') 
            return
        end
        if all(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
            fit_single_point(obj)
        elseif not(any(cellfun(@isempty, obj.fitdata.fitobjects), 'all'))
            if not(request_user_refit_all)
                enable_gui('on')
                return
            end
        end
        fit_all_transmission(obj)
        set_plotmethods_fitted_data(obj)
        enable_gui(obj, 'on')
    end

    function show_fit_button_pushed(obj)
        % Enable only if all fits are made. 
        if any(cellfun(@isempty, obj.fitdata.fitobjects), 'all')
            uialert(obj.datapicker.UIFigure, ['No fitdata present for ' ...
                'all points. Please fit all data first.'], ...
                'Incomplete fitdata', 'Icon', 'Info')
            obj.datapicker.ShowFitsButton.Value = 0; 
        end
    end

    function changed_plottype_rgb(obj)
        % change the rgb data for the color plot. 
        set_rgb_transmission(obj);
        plot_rgb_transmission(obj);
    end

end

