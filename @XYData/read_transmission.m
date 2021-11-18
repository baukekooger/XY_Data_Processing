function [ obj ] = read_transmission(obj)
% reads the transmission data from the file as is


%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

%% Prepare and set required variables

obj.spectrometer.wavelengths = unique(h5read(obj.fname, '/dark/emission'));
wavelengths_size = length(obj.spectrometer.wavelengths);

obj.spectrometer.darkspectrum = NaN(wavelengths_size);
obj.spectrometer.lampspectrum = NaN(wavelengths_size); 
obj.spectrometer.spectra = NaN(obj.xystage.xnum, obj.xystage.ynum, wavelengths_size);
obj.xystage.coordinates = NaN(obj.xystage.xnum, obj.xystage.ynum, 2);

obj.spectrometer.darkspectrum = h5read(obj.fname, '/dark/spectrum'); 
obj.spectrometer.lampspectrum = h5read(obj.fname, '/lamp/spectrum') - ...
    obj.spectrometer.darkspectrum; 

%% reading in all data 

for x=1:obj.xystage.xnum
    for y=1:obj.xystage.ynum
        group = sprintf('/x%dy%d/',x,y);
        spectrum = h5read(obj.fname, [group 'spectrum'])';
        obj.spectrometer.spectra(x,y,:) = spectrum;
        obj.xystage.coordinates(x,y,:) = h5read(obj.fname, ...
                [group 'position']);
    end
end


%% permute the data for the imagesc function 
% The permutation is there to rotate the plot 90 degrees.

obj.spectrometer.spectra = (permute(obj.spectrometer.spectra, [2 1 3]));
obj.xystage.coordinates = (permute(obj.xystage.coordinates, [2 1 3]));

end

