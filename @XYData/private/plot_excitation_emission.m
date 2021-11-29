function plot_excitation_emission(obj)
% Create an instance of the excitation emission datapicker and plotwindow.
% Provide some intial setup of ui elements such as populating tables and
% comboboxes with the right data. 
% Connect ui element interaction callbacks to different data and plotting 
% operations. 

    obj.datapicker = picker_excitation_emission;
    obj.plotwindow.figure = figure();
    obj.plotwindow.ax_spectrum = subplot(1,5, [1 4]);
    obj.plotwindow.ax_rgb = subplot(1,5,5);
    
    %% initialize the ui components

    % init the emission wavelength and emission peak spinners
    min_wl = obj.spectrometer.wavelengths(1); 
    max_wl = obj.spectrometer.wavelengths(end); 
    step = mean(diff(obj.spectrometer.wavelengths)); 
    
    obj.datapicker.MinWavelengthSpinner.Limits = [min_wl, max_wl]; 
    obj.datapicker.MinWavelengthSpinner.Step = step; 
    obj.datapicker.MinWavelengthSpinner.Value = min_wl; 
    
    obj.datapicker.MaxWavelengthSpinner.Limits = [min_wl, max_wl]; 
    obj.datapicker.MaxWavelengthSpinner.Step = step; 
    obj.datapicker.MaxWavelengthSpinner.Value = max_wl;  

    obj.datapicker.EmissionWavelengthSpinner.Limits = [min_wl, max_wl]; 
    obj.datapicker.EmissionWavelengthSpinner.Step = step; 
    obj.datapicker.EmissionWavelengthSpinner.Value = max_wl;  
    
    % init the excitation wavelength spinners  
    min_ex_wl = min(obj.laser.excitation_wavelengths);
    max_ex_wl = max(obj.laser.excitation_wavelengths); 
    step = mean(diff(obj.laser.excitation_wavelengths)); 

    obj.datapicker.MinExWavelengthSpinner.Limits = [min_ex_wl, max_ex_wl]; 
    obj.datapicker.MinExWavelengthSpinner.Step = step; 
    obj.datapicker.MinExWavelengthSpinner.Value = min_ex_wl; 
    
    obj.datapicker.MaxExWavelengthSpinner.Limits = [min_ex_wl, max_ex_wl]; 
    obj.datapicker.MaxExWavelengthSpinner.Step = step; 
    obj.datapicker.MaxExWavelengthSpinner.Value = max_ex_wl;  

    excitation_wavelengths = string(obj.laser.excitation_wavelengths); 
    obj.datapicker.ExcitationWavelengthsListBox.Items = ...
        excitation_wavelengths; 

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
    obj.datapicker.SetSpectraButton.ButtonPushedFcn = ...
        @(src, event)set_spectra(obj);
    obj.datapicker.MinWavelengthSpinner.ValueChangedFcn = ...
        @(src, event)wavelength_range_changed_spinner(obj, src, event); 
    obj.datapicker.MaxWavelengthSpinner.ValueChangedFcn = ...
        @(src, event)wavelength_range_changed_spinner(obj, src, event); 
    obj.datapicker.ClickMinWavelengthCheckBox.ValueChangedFcn = ...
        @(src, event)assert_checkboxes_wavelength(obj, src); 
    obj.datapicker.ClickMaxWavelengthCheckBox.ValueChangedFcn = ...
        @(src, event)assert_checkboxes_wavelength(obj, src); 
    obj.datapicker.ResetRangeButton.ButtonPushedFcn = ...
        @(src, event)reset_wavelength_range(obj); 
     obj.datapicker.DarkSpectrumButton.ButtonPushedFcn = ...
        @(src, event)plot_darkspectrum(obj); 
     obj.datapicker.BeamsplitterCalibrationButton.ButtonPushedFcn = ...
        @(src, event)plot_beamsplitter_calibration(obj); 


    %% call the rgb function to plot an initial XY color chart
    set_rgb_excitation_emission(obj);
    plot_rgb_excitation_emission(obj);

    %% define sequenced callbacks
    function datatip_text_xy =  wrapper_cursor_clicked_xy(event, obj)
        % Set the xy datapicker cursor datatip text and plot the
        % corresponding spectra in the plotwindow. 
        x = event.Position(1);
        y = event.Position(2); 
        datatip_text_xy = sprintf('X = %.1f, Y = %.1f', x, y); 
        plot_cursor_selection_excitation_emission(obj);
    end

    function datatip_text_plotwindow = ...
        wrapper_cursor_clicked_plotwindow(event, obj) 
        % Set the plotwindow cursor datatip value and set the wavelength
        % of corresponding spinner if check is passed. 
        wl = event.Position(1);
        if not(check_range_wavelength_cursor(obj))
            datatip_text_plotwindow = ['Minimum wavelength should be ' ...
                'smaller than maximum wavelength']; 
            return
        end
        datatip_text_plotwindow = sprintf('wavelength = %.2f', wl); 
        select_nearest_wavelength(obj)
        draw_lines_wavelength_range(obj);
    end

    function set_spectra(obj)
        % Set the spectra with the settings from the ui, replot the color
        % charts and the cursor selection for the new spectra.
        set_spectra_excitation_emission(obj);
        set_rgb_excitation_emission(obj);
        plot_rgb_excitation_emission(obj);
        plot_cursor_selection_excitation_emission(obj);
    end

    function wavelength_range_changed_spinner(obj, src, event)
        if not(check_range_wavelength_spinner(obj, src, event))
            return
        end
        select_nearest_wavelength(obj) 
        draw_lines_wavelength_range(obj)
    end

    function reset_wavelength_range(obj)
        reset_wavelengths(obj)
        set_spectra(obj) 
    end

end


