function plot_darkspectrum(obj)
% Plot the dark spectrum. Remove any other lines visible in the plot. 
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'Line'))    

    switch obj.experiment
        case('transmission')
            wavelengths = obj.plotdata.wavelengths_transmission; 
            darkspectrum = obj.plotdata.darkspectrum_transmission; 
            minwl = obj.plotdata.wavelengths_transmission(1); 
            maxwl = obj.plotdata.wavelengths_transmission(end); 
        case('excitation_emission')
            wavelengths = obj.plotdata.wavelengths_emission;
            darkspectrum = obj.plotdata.darkspectrum_emission; 
            minwl = obj.plotdata.wavelengths_emission(1); 
            maxwl = obj.plotdata.wavelengths_emission(end); 
    end

    plot(obj.plotwindow.ax_spectrum, wavelengths, darkspectrum)

    title(obj.plotwindow.ax_spectrum, 'Dark Spectrum') 
    ylabel(obj.plotwindow.ax_spectrum, 'Counts')
    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])

    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel('Wavelength [nm]')

end

