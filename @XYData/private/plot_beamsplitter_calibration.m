function plot_beamsplitter_calibration(obj)
% Check if there is beamsplitter data. If not, notify user. If there is,
% plot the beamsplitter calibration data. 

    if isempty(obj.beamsplitter.correction_pm_to_sample)     
        fig = uifigure;
        msg = ['No beamsplitter calibration data was found. ' ...
            'Do you want to manually select a calibration file?'];
        title = 'No calibration data';
        selection = uiconfirm(fig, msg, title, ...
           'Options',{'Select file', ... 
           'Cancel'});
        switch selection
            case 'Select file'
                close(fig)
                clear('fig')
                fname = uigetfile('*.csv'); 
                read_calibration_beamsplitter_csv(obj, fname); 
            case 'Cancel'
                close(fig)
                clear('fig') 
                return
        end
    end
      
    delete(findobj(obj.plotwindow.ax_spectrum, 'Type', 'Line'))    
    plot(obj.plotwindow.ax_spectrum, ...
         obj.beamsplitter.wavelengths, ...
         obj.beamsplitter.correction_pm_to_sample)
    ylabel(obj.plotwindow.ax_spectrum, 'Ratio sample to powermeter')
    ylim(obj.plotwindow.ax_spectrum, [-Inf, Inf])
    minwl = obj.beamsplitter.wavelengths(1); 
    maxwl = obj.beamsplitter.wavelengths(end); 
    xlim(obj.plotwindow.ax_spectrum, [minwl, maxwl])
    xlabel(obj.plotwindow.ax_spectrum, 'Wavelength [nm]')
    obj.plotwindow.ax_spectrum.Title.String = ['Beamsplitter ', ...
        'Calibration, Model = ', obj.beamsplitter.model, ', Cal. Date = ', ...
        obj.beamsplitter.calibration_date];
    
end

