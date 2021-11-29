function plot_lampspectrum(obj)
% Plot the lamp spectrum. The lamp spectrum has the dark spectrum already
% Remove any other lines visible in the plot. 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'Line'))    
    plot(obj.plotwindow.ax_spectrum, ...
        obj.plotdata.wavelengths_transmission, ...
        obj.plotdata.lampspectrum)
    title(obj.plotwindow.ax_spectrum, 'Lamp Spectrum Minus Dark Spectrum') 
    ylabel(obj.plotwindow.ax_spectrum, 'Counts')
    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])
    minwl = obj.plotdata.wavelengths_transmission(1); 
    maxwl = obj.plotdata.wavelengths_transmission(end); 
    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel('Wavelength [nm]')
end

