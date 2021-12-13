function obj = plot_rgb_excitation_emission(obj)
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
        x = sample_width/2 + offset_left/2 - offset_right/2; 
    end
    
    if obj.xystage.ynum > 1
        y = squeeze(obj.xystage.coordinates(:,:,2)); 
        y = y - min(y, [], 'all'); 
        y = y + offset_bottom; 
    else
        y = sample_height/2 + offset_bottom/2 - offset_top/2; 
    end
    
    if obj.xystage.xnum == 1 || obj.xystage.ynum == 1
        [x, y] = meshgrid(x, y); 
    end
    x = double(x); 
    y = double(y); 
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
    
    % Plot the colorchart for measurements where both x and y have a 
    % minimum of two points. 

    if size(obj.xystage.coordinates, 1) > 1 && ...
            size(obj.xystage.coordinates, 2) > 1
        % Plot the colorchart if none exists. flipping the data is 
        % necessary for correct display. If it exists, update the 
        % color data. 
        colorsurface = findobj(obj.datapicker.UIAxes, 'Type', 'Surface');
        if isempty(colorsurface)
            colorsurface = pcolor(obj.datapicker.UIAxes, x, y, ...
                flipud(obj.plotdata.rgb));
            colorsurface.FaceColor = 'interp';
            caxis(obj.datapicker.UIAxes, 'auto')
        else
            colorsurface.CData = flipud(obj.plotdata.rgb);  
        end
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
    
    % Format axes
    xunique = reshape(unique(x), 1, []); 
    yunique = reshape(unique(y), 1, []); 
    obj.datapicker.UIAxes.XTick = [0, xunique, sample_width]; 
    obj.datapicker.UIAxes.YTick =  [0, yunique, sample_height];
    obj.datapicker.UIAxes.XLim =  [0 sample_width];
    obj.datapicker.UIAxes.YLim =  [0 sample_height]; 
    xtickformat(obj.datapicker.UIAxes, '%.1f')
    ytickformat(obj.datapicker.UIAxes, '%.1f')
    axis(obj.datapicker.UIAxes, 'image') 
    
    % Set title. 
    rgbtitle = make_title(obj, true); 
    title(obj.datapicker.UIAxes, rgbtitle)
    
    % Add subtitle if multiple excitation wavelengths are chosen.
    if length(obj.datapicker.ExcitationWavelengthsListBox.Value) > 1 ...
            && strcmp(obj.datapicker.SpectraDropDown.Value, 'Emission')
        subtitle(obj.datapicker.UIAxes, ...
            ['Multiple excitation wavelengths, ' ...
            'color plot shows average']);
    else
        subtitle(obj.datapicker.UIAxes, '');
    end

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
    
    % plot the colorchart if more than 1 x and y point.
    if size(obj.xystage.coordinates, 1) > 1 && ...
            size(obj.xystage.coordinates, 2) > 1
        % plot the colorchart. flipping the data is necessary for correct 
        % display
        colorsurface = pcolor(obj.plotwindow.ax_rgb, x, y, ...
            flipud(obj.plotdata.rgb));
        colorsurface.FaceColor = 'interp';
        caxis(obj.plotwindow.ax_rgb, 'auto')
        
    end
    xlabel('x (mm)')
    ylabel('y (mm)')
    
    % Set title. 
    rgbtitle = make_title(obj, false); 
    title(obj.plotwindow.ax_rgb, rgbtitle)

    axis(obj.plotwindow.ax_rgb, 'image') 
    hold(obj.plotwindow.ax_rgb, 'off')
end

function rgbtitle = make_title(obj, withsample)
% Set the title based on the current setting for the rgb plot. 

    sample = clean_string(obj.sample); 

    % No color plot available when either xnum or ynum 1. 
    if size(obj.xystage.coordinates, 1) < 2 || ...
        size(obj.xystage.coordinates, 2) < 1

        if withsample
            rgbtitle = {[sample ' - sample outline']}; 
        else
            rgbtitle = 'Sample outline'; 
        end
        return
    end

    parameter = obj.datapicker.ColorChartDropDown.Value;
    switch parameter
        case 'default'
            rgbtitle = {[sample ' - sum of spectrum']};
        case coeffnames(obj.fitdata.fitobjects{1,1,1})
            if strcmp(parameter, 'a')
                rgbtitle = {[sample ' - Amplitude of'], 'fitted gaussian'}; 
            elseif contains(parameter, 'a')
                rgbtitle = {[sample ' - Amplitude of'], [' fitted '...
                    'gaussian ' erase(parameter, 'a')]};
            elseif strcmp(parameter, 'b')
                rgbtitle = {[sample ' - Peak wavelength of '], ...
                    'fitted gaussian'}; 
            elseif contains(parameter, 'b')
                rgbtitle = {[sample ' - Peak wavelength of'], ...
                    [' fitted gaussian ' erase(parameter, 'b')]};
            elseif strcmp(parameter, 'c')
                rgbtitle = {[sample ' - Peak width (nm) of '], ...
                    'fitted gaussian'}; 
            elseif contains(parameter, 'c')
                rgbtitle = {[sample ' - Peak width (nm) of '], ...
                    ['fitted gaussian ' erase(parameter, 'b')]};
            end
        case 'sse' 
            rgbtitle = {[sample ' - Sum of squared'], ...
                ' error of fit (SSE)'};
        case 'rsquare' 
            rgbtitle = {[sample ' - RSquare value'], 'of fit'};
        case 'dfe' 
            rgbtitle = {[sample ' - Degrees of freedom'], ...
                ' error of fit'};
        case 'adjrsquare' 
            rgbtitle = {[sample ' - Degrees of freedom '], ...
                'adjusted RSquare of fit'};
        case 'rmse' 
            rgbtitle = {[sample ' - Root mean squared error']};
    end

    if not(withsample)
        rgbtitle = erase(rgbtitle, [sample ' - ']); 
        rgbtitle{1}(1) = upper(rgbtitle{1}(1)); 
    end
end