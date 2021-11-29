function read_transmission(obj)
% reads the transmission data from the file as is

%% Prepare and set required variables

    obj.spectrometer.wavelengths = unique(h5read(obj.fname, ...
        '/dark/emission'));
    % rounding wavelengths to prevent errors finding wavelength indices 
    % later.
    obj.spectrometer.wavelengths = ...
        round(obj.spectrometer.wavelengths, 2); 
    wavelengths_size = length(obj.spectrometer.wavelengths);
    
    obj.spectrometer.darkspectrum = NaN(wavelengths_size);
    obj.spectrometer.lampspectrum = NaN(wavelengths_size); 
    obj.spectrometer.spectra = ...
        NaN(obj.xystage.ynum, obj.xystage.xnum, wavelengths_size);
    obj.xystage.coordinates = ...
        NaN(obj.xystage.ynum, obj.xystage.xnum, 2);
    
    obj.spectrometer.darkspectrum = h5read(obj.fname, '/dark/spectrum'); 
    obj.spectrometer.lampspectrum = ...
        h5read(obj.fname, '/lamp/spectrum') - ...
        obj.spectrometer.darkspectrum; 

%% Read in all the data 

for y=1:obj.xystage.ynum
    for x=1:obj.xystage.xnum
        group = sprintf('/x%dy%d/',x,y);
        spectrum = h5read(obj.fname, [group 'spectrum'])';
        obj.spectrometer.spectra(y,x,:) = spectrum;
        obj.xystage.coordinates(y,x,:) = h5read(obj.fname, ...
                [group 'position']);
    end
end

end

