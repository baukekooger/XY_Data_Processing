function save_plot(obj)
% Saves the selected figure in a matlab fig. In the case of a single plot,
% it resets the axes position first. 
    
    extensions_choosefile = {'*.fig'; '*.jpg'; '*.png'}; 
    extensions_writefile = {'.fig'; '.jpg' ; '.png'}; 
    [filename, path, idx] = uiputfile(extensions_choosefile, ...
        'Select directory, filename and filetype to save figue'); 
    
    if not(filename)
        return
    end

    switch obj.datapicker.SelectPlotDropDown.Value
        case 'Spectrum Plot'
            fig = figure; 
            ax_spectrum = copyobj(obj.plotwindow.ax_spectrum, fig); 
            subplot(1,1,1, ax_spectrum); 
        case 'Color Chart'
            fig = figure; 
            ax_spectrum = copyobj(obj.plotwindow.ax_rgb, fig); 
            subplot(1,1,1, ax_spectrum); 
        case 'Together'
            fig = obj.plotwindow.figure;        
    end

    if strcmp(extensions_writefile{idx}, '.fig')
        savefig(fig, [path '\' filename])
    else
        saveas(fig, [path '\' filename])   
    end
end

