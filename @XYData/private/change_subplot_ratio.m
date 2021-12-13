function change_subplot_ratio(obj)
% Change the subplot settings for the plotwindow based on the size of the
% spectrum and color chart size from the corresponding ui spinners. Plots
% are always on a horizontal line. 

    size_spectrum = obj.datapicker.SizeSpectrumSpinner.Value; 
    size_rgb = obj.datapicker.SizeColorChartSpinner.Value; 
    total_size = size_spectrum + size_rgb; 

    subplot(1, total_size, 1:size_spectrum, obj.plotwindow.ax_spectrum); 
    subplot(1, total_size, ...
        (size_spectrum + 1):(size_spectrum + size_rgb), ...
        obj.plotwindow.ax_rgb); 

end

    



