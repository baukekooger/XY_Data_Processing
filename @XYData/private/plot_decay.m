function plot_decay(obj)

% Create an instance of the decay datapicker and plotwindow.
% Provide some intial setup of ui elements such as populating tables and
% comboboxes with the right data. 
% Connect ui element interaction callbacks to different data and plotting 
% operations. 

obj.datapicker = picker_decay;
obj.plotwindow.figure = figure();
% initialize plotwindow with spectrum axes and rgb axes, this can be 
% modified in the ui by the user 
obj.plotwindow.ax_spectrum = subplot(1,5, [1 4]);
obj.plotwindow.ax_rgb = subplot(1,5,5);


%% initialize ui components
% set the limit for the stop spinner at the maximum value
upperlimit = double(obj.digitizer.samples-1) / ... 
    double(obj.digitizer.sample_rate); 
step = double(1 / obj.digitizer.sample_rate);
obj.datapicker.StartTimeSpinner.Limits = [0 upperlimit];
obj.datapicker.StartTimeSpinner.Step = step;
obj.datapicker.StopTimeSpinner.Limits = [0 upperlimit];
obj.datapicker.StopTimeSpinner.Step = step;
obj.datapicker.StopTimeSpinner.Value = upperlimit; 
% set the excitation wavelengths selection 
obj.datapicker.ExcitationWavelengthListBox.Items = ...
    string(obj.laser.excitation_wavelengths); 

% set the default color chart option and disable the dropdown.
obj.datapicker.ColorChartPlotTypeDropDown.Items = {'default'}; 
obj.datapicker.ColorChartPlotTypeDropDown.Enable = 'off'; 

% set the possible compression factors 
set_compression_factors(obj) 

% connect the ui activity to callback functions
%% intialze and connect data cursors
obj.datacursor.xy = datacursormode(obj.datapicker.UIFigure);
obj.datacursor.xy.Enable = 'on';
obj.datacursor.xy.UpdateFcn = @wrapper_cursor_clicked_xy;
obj.datacursor.plotwindow = datacursormode(obj.plotwindow.figure); 
obj.datacursor.plotwindow.Enable = 'on'; 
obj.datacursor.plotwindow.UpdateFcn = @wrapper_cursor_clicked_plotwindow;

%% connect ui elements
obj.datapicker.ResetButton.ButtonPushedFcn = @wrapper_reset; 
obj.datapicker.NormalizeSelectedButton.ButtonPushedFcn = ...
    @wrapper_normalize_selection;  
obj.datapicker.ExcitationWavelengthListBox.ValueChangedFcn = ...
    @excitation_wavelength_changed;  
obj.datapicker.StartTimeSpinner.ValueChangedFcn = ...
    @time_range_changed_spinner; 
obj.datapicker.StopTimeSpinner.ValueChangedFcn = ...
    @time_range_changed_spinner;  
obj.datapicker.ClickStartCheckBox.ValueChangedFcn = ... 
    @(src, event)assert_checkboxes_clickstartstoptime(obj, src); 
obj.datapicker.ClickStopCheckBox.ValueChangedFcn = ... 
    @(src, event)assert_checkboxes_clickstartstoptime(obj, src); 
obj.datapicker.FitTypeDropDown.ValueChangedFcn = ...
    @(src, event)fittype_changed_decay(obj); 
obj.datapicker.ShowFitSelectedPointsButton.ValueChangedFcn = ...
    @(src, event)plot_cursor_selection_decay(obj);
obj.datapicker.FitAllButton.ButtonPushedFcn = ...
    @(src, event)fit_all_decay(obj); 
obj.datapicker.ScaleYAxisDropDown.ValueChangedFcn = ...
    @(src, event)change_scale_y_axis(obj, event);  
obj.datapicker.DataCompressionDropDown.ValueChangedFcn = ...
    @(src, event)wrapper_normalize_selection(obj); 
obj.datapicker.ColorChartPlotTypeDropDown.ValueChangedFcn = ...
    @(src, event)plottype_changed(obj);
obj.datapicker.ColorMinEditField.ValueChangedFcn = ...
    @color_limits_changed; 
obj.datapicker.ColorMaxEditField.ValueChangedFcn = ...
    @color_limits_changed; 
obj.datapicker.ResetLimitsButton.ButtonPushedFcn = ...
    @(src, event)plot_rgb_decay(obj); 

%% call the plot rgb function to plot an initial XY color chart 
set_rgb_decay(obj);
plot_rgb_decay(obj);
fittype_changed_decay(obj); 


%% callback functions  

    function cursortext_xy =  wrapper_cursor_clicked_xy(~, event)
        x = event.Position(1);
        y = event.Position(2); 
        cursortext_xy = sprintf('X = %.1f, Y = %.1f', x, y); 
        plot_cursor_selection_decay(obj);
    end

    function cursortext_plotwindow = ...
            wrapper_cursor_clicked_plotwindow(~, event) 
        % Click in the decay trace plotwindow to set the time limits. 
        time = event.Position(1);
        cursortext_plotwindow = sprintf('t = %.2e', time); 
        if not(set_time_limit_cursor(obj))
            return
        end
        draw_time_limit_lines(obj);
    end

    function wrapper_reset(varargin) 
        % Reset the selected time range
        reset_spectra_decay(obj);
        reset_fitdata(obj);
        set_plotmethods_fitted_data(obj);
        set_rgb_decay(obj); 
        plot_rgb_decay(obj);
        plot_cursor_selection_decay(obj);
    end

    function wrapper_normalize_selection(varargin)
        % Normalize the traces to the maximum value in selected time range 
        set_spectra_decay(obj);
        reset_fitdata(obj);
        set_plotmethods_fitted_data(obj);
        set_rgb_decay(obj);
        plot_rgb_decay(obj);
        plot_cursor_selection_decay(obj);
    end

    function excitation_wavelength_changed(varargin) 
        % Set the spectra to the newly selected excitation wavelength
        set_spectra_decay(obj);
        reset_fitdata(obj);
        set_plotmethods_fitted_data(obj);
        set_rgb_decay(obj);
        plot_rgb_decay(obj);
        plot_cursor_selection_decay(obj);
    end

    function plottype_changed(obj)
       set_rgb_decay(obj) ;
       plot_rgb_decay(obj);
       plot_cursor_selection_decay(obj);
    end

    function time_range_changed_spinner(src, event)
        % Check if correct time limits entered and draw time limit lines. 
        if not(check_time_range(obj, src, event))
            return
        end
        draw_time_limit_lines(obj);
    end

    function color_limits_changed(src, event)
        % check if the min limit is not higher than the max limit
        if not(check_color_limits(obj, src, event))
            return
        end  
        update_color_limits(obj) 
    end

    function fittype_changed_decay(obj)
        set_fittype_decay(obj)
        reset_fitdata(obj); 
        set_plotmethods_fitted_data(obj);
        set_rgb_decay(obj);
        plot_rgb_decay(obj);
        plot_cursor_selection_decay(obj)
    end

end
    

