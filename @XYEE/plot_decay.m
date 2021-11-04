function obj = plot_decay(obj)

% Create an instance of the decay datapicker and a dedicated plotwindow. 
% Connect ui buttons to different data and plotting operations. The ui 
% element callbacks are connected to wrapper functions which call one or
% multiple methods on the XYEE object. 

obj.datapicker = picker_decay;
obj.plotwindow.figure = figure();
% initialize plotwindow with spectrum axes and rgb axes, this can be 
% modified in the ui by the user 
obj.plotwindow.ax_spectrum = subplot(1,5, [1 4]);
obj.plotwindow.ax_rgb = subplot(1,5,5);

% setup the limit and step values of the ui data selection spinner. 
% set the limit for the stop spinner at the maximum value
upperlimit = double(obj.digitizer.samples) / ... 
    double(obj.digitizer.sample_rate); 
step = double(1 / obj.digitizer.sample_rate);
obj.datapicker.StartTimeSpinner.Limits = [0 upperlimit];
obj.datapicker.StartTimeSpinner.Step = step;
obj.datapicker.StopTimeSpinner.Limits = [0 upperlimit];
obj.datapicker.StopTimeSpinner.Step = step;
% set the excitation wavelengths selection 
obj.datapicker.ExcitationWavelengthListBox.Items = ...
    string(obj.laser.excitation_wavelengths); 

% connect the ui activity to wrapper functions for plotting methods
% - data cursors
obj.datacursor.xy = datacursormode(obj.datapicker.UIFigure);
obj.datacursor.xy.Enable = 'on';
obj.datacursor.xy.UpdateFcn = @wrapper_cursor_clicked_xy;
obj.datacursor.plotwindow = datacursormode(obj.plotwindow.figure); 
obj.datacursor.plotwindow.Enable = 'on'; 
obj.datacursor.plotwindow.UpdateFcn = @wrapper_cursor_clicked_plotwindow; 
% - ui elements
obj.datapicker.ResetButton.ButtonPushedFcn = @wrapper_reset; 
obj.datapicker.NormalizeSelectedButton.ButtonPushedFcn = ...
    @wrapper_normalize_selection;  
obj.datapicker.ExcitationWavelengthListBox.ValueChangedFcn = ...
    @wrapper_excitation_wavelength_changed;  
obj.datapicker.StartTimeSpinner.ValueChangedFcn = ...
    @wrapper_time_range_changed; 
obj.datapicker.StopTimeSpinner.ValueChangedFcn = ...
    @wrapper_time_range_changed;  
obj.datapicker.ClickStartCheckBox.ValueChangedFcn = ... 
    @wrappper_click_plot_limits_changed; 
obj.datapicker.ClickStopCheckBox.ValueChangedFcn = ... 
    @wrappper_click_plot_limits_changed; 

% call the plot rgb function to plot an initial XY color chart 
rgb_decay_set(obj)
pause(0.1)
rgb_decay_plot(obj)
pause(0.1)


    function cursortext_xy =  wrapper_cursor_clicked_xy(~, event)
        x = event.Position(1);
        y = event.Position(2); 
        cursortext_xy = sprintf('X = %.1f, Y = %.1f', x, y); 
        plot_cursor_selection_decay(obj) 
    end

    function wrapper_cursor_clicked_plotwindow(varargin) 
        disp('called wrapper clicked plotwindow') 
        % check start_stop_limits(obj) 
    end

    function wrapper_reset(varargin) 
        disp('called wrapper reset')
    end

    function wrapper_normalize_selection(varargin)
        disp('called wrapper normalize function')
    end
    
    function wrapper_excitation_wavelength_changed(varargin) 
        set_spectra_decay(obj)
        rgb_decay_set(obj)
        rgb_decay_plot(obj)
        plot_cursor_selection_decay(obj)
    end

    function wrapper_time_range_changed(src, event)
        if not(check_time_range_limits(obj, src, event))
            return
        end

    end

    function wrappper_click_plot_limits_changed(src, event)
        click_plot_limits_changed(obj, src, event);
    end

end

