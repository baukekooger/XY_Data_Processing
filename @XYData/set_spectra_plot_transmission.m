function obj = set_spectra_plot_transmission(obj, plottype)
% Sets the plotdata spectra to raw spectra, subtracted dark or transmission
% spectra depending on the plottype argument. This is selected in the UI
% app

darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
        obj.xystage.xnum, obj.xystage.ynum);
darkrepeat = permute(darkrepeat, [2 3 1]); 

lamprepeat = repmat(obj.spectrometer.lampspectrum, 1, ...
        obj.xystage.xnum, obj.xystage.ynum);
lamprepeat = permute(lamprepeat, [2 3 1]);

switch plottype
    case 'Raw Data'
        obj.plotdata.spectra_transmission = obj.spectrometer.spectra; 
    case 'Dark Removed'
        obj.plotdata.spectra_transmission = obj.spectrometer.spectra ...
            - darkrepeat;
    case 'Transmission'
        obj.plotdata.spectra_transmission = obj.spectrometer.spectra ...
            - darkrepeat; 
        obj.plotdata.spectra_transmission = ...
            obj.plotdata.spectra_transmission ./ lamprepeat;
end  
    
