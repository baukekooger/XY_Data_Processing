function plot_darkspectrum(obj)
% Plot the dark spectrum. Remove any other lines visible in the plot. 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'Line'))    
    plot(obj.plotwindow.ax_spectrum, ...
         obj.plotdata.wavelengths_emission, ...
         obj.plotdata.darkspectrum_emission)
    title(obj.plotwindow.ax_spectrum, 'Dark Spectrum') 
    ylabel(obj.plotwindow.ax_spectrum, 'Counts')
    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])
    minwl = obj.plotdata.wavelengths_emission(1); 
    maxwl = obj.plotdata.wavelengths_emission(end); 
    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel('Wavelength [nm]')
end

