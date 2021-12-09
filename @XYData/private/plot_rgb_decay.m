function plot_rgb_decay(obj) 
% plot the rgb values on the datapicker window and the plotwindow if the 
% plotwindow has the plot enabled. 

    %% read the spacing values and set xy positions for plotting 
    offset_left = obj.xystage.offset_left; 
    offset_right = obj.xystage.offset_right;
    offset_bottom = obj.xystage.offset_bottom;  
    offset_top = obj.xystage.offset_top; 
    sample_width = obj.xystage.sample_width;  
    sample_height = obj.xystage.sample_height;  
    
    if obj.xystage.xnum > 1
        x = squeeze(obj.xystage.coordinates(:,:,1)); 
        x = x - min(x, [], 'all');
        x = x + offset_left; 
    else
        x = sample_width/2 + offset_left - offset_right; 
    end
    
    if obj.xystage.ynum > 1
        y = squeeze(obj.xystage.coordinates(:,:,2)); 
        y = y - min(y, [], 'all'); 
        y = y + offset_bottom; 
    else
        y = sample_height/2 + offset_bottom - offset_top; 
    end
    
    obj.plotdata.xy_coordinates = cat(3, x, y); 

    %% plot the xy chart on the datapicker window

    % hold the axes on for the different plots
    hold(obj.datapicker.UIAxes, 'on')
    
    % Plot the outline of the sample if not present
    if isempty(findobj(obj.datapicker.UIAxes, 'Type', 'Rectangle'))
        rectangle(obj.datapicker.UIAxes, 'Position', ...
            [0 0 sample_width sample_height], ...
            'FaceColor', [0.8431, 0.9451, 0.9804]);
    end 

    if size(obj.xystage.coordinates, 1) > 1 && ...
        size(obj.xystage.coordinates, 2) > 1
        % Plot the colorchart if none exists. flipping the data is necessary for 
        % correct display. If it exists, update the color data. 
        colorsurface = findobj(obj.datapicker.UIAxes, 'Type', 'Surface');
        if isempty(colorsurface)
            colorsurface = pcolor(obj.datapicker.UIAxes, x, y, ...
                flipud(obj.plotdata.rgb));
            colorsurface.FaceColor = 'interp';
            caxis(obj.datapicker.UIAxes, 'auto')
        else
            colorsurface.CData = flipud(obj.plotdata.rgb);  
        end
        colorbar(obj.datapicker.UIAxes)
        % Set limits in the colorplot and also in the edit fields
        mincolor = min(colorsurface.CData, [], "all"); 
        maxcolor = max(colorsurface.CData, [], "all"); 
        if mincolor == maxcolor
            mincolor = mincolor * 0.9;
            maxcolor = maxcolor * 1.1;
        end
        caxis(obj.datapicker.UIAxes, [mincolor maxcolor]); 
        obj.datapicker.ColorMinEditField.Value = mincolor; 
        obj.datapicker.ColorMaxEditField.Value = maxcolor; 
    end
        
    
    % Plot the measurement points if none are available
    if isempty(findobj(obj.datapicker.UIAxes, 'Type', 'Line'))
        plot(obj.datapicker.UIAxes, x, y, 'o', 'MarkerFaceColor', ...
            'w', 'MarkerEdgeColor','k'); 
    end
    
    obj.datapicker.UIAxes.XTick = [0; unique(x); sample_width]; 
    obj.datapicker.UIAxes.YTick =  [0; unique(y); sample_height];
    obj.datapicker.UIAxes.XLim =  [0 sample_width];
    obj.datapicker.UIAxes.YLim =  [0 sample_height]; 
    xtickformat(obj.datapicker.UIAxes, '%.1f')
    ytickformat(obj.datapicker.UIAxes, '%.1f')
    axis(obj.datapicker.UIAxes, 'image') 
    
    % Set title if no fitdata is available

    sample = clean_string(obj.sample);
    switch obj.datapicker.ColorChartDropDown.Value
        case 'default'
            rgbtitle = [sample ' - sum of spectrum for ' ...
                'selected timerange'];
        case 'C'
            rgbtitle = [sample ' - Fit parameter C'];
        case 'C1'
            rgbtitle = [sample ' - Fit parameter C1'];
        case 'C2'
            rgbtitle = [sample ' - Fit parameter C2'];
        case 'tau'
            rgbtitle = [sample ' - Decay time constant ' ...
                '\tau from fit (\mus)'];
        case 'tau_1' 
            rgbtitle = [sample ' - Decay time constant \tau_1 ' ...
                'from fit (\mus)'];
        case 'tau_2' 
            rgbtitle = [sample ' - Decay time constant \tau_2 ' ...
                'from fit (\mus)'];
        case 'sse' 
            rgbtitle = [sample ' - Sum of squares error of fit (SSE)'];
        case 'rsquare' 
            rgbtitle = [sample ' - RSquare value of fit'];
        case 'dfe' 
            rgbtitle = [sample ' - Degrees of freedom error of fit'];
        case 'adjrsquare' 
            rgbtitle = [sample ' - Degrees of freedom ' ...
                'adjusted RSquare of fit'];
        case 'rmse' 
            rgbtitle = [sample ' - Root mean squared error'];
    end
    title(obj.datapicker.UIAxes, rgbtitle)
    
    hold(obj.datapicker.UIAxes, 'off')
    
    %% plot the xy chart on the plotwindow indicator if available. 
    if isempty(obj.plotwindow.ax_rgb)
        return 
    end
    
    hold(obj.plotwindow.ax_rgb, 'on')
    
    % remove all previously made lines, surfaces and rectangles
    delete(findobj(obj.plotwindow.ax_rgb, ...
        {'Type','Line', '-or', 'Type', 'Rectangle', '-or', ...
        'Type', 'Surface'}))
    
    % plot the outline of the sample
    rectangle(obj.plotwindow.ax_rgb, 'Position', ...
        [0 0 sample_width sample_height], ...
        'FaceColor', [0.8431, 0.9451, 0.9804]);
    
    if size(obj.xystage.coordinates, 1) > 1 && ...
        size(obj.xystage.coordinates, 2) > 1
        % plot the colorchart. flipping the data is necessary for correct display
        colorsurface = pcolor(obj.plotwindow.ax_rgb, x, y, ...
            flipud(obj.plotdata.rgb));
        colorsurface.FaceColor = 'interp';
        caxis(obj.plotwindow.ax_rgb, 'auto')
        axis(obj.plotwindow.ax_rgb, 'image') 
    end
    
    hold(obj.plotwindow.ax_rgb, 'off')

end

