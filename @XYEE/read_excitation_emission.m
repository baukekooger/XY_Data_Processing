function [ obj ] = read_excitation_emission( obj )
% reads the data from the HDF5 file and puts stores in in the XYEE object
% does not modify any of the data apart from permutations 

%% Preallocating some matrices and reading single groups
finfo = h5info(obj.fname);
dimnames = {finfo.Datasets.Name};
dimsizes = cellfun(@(x)(x.Size),{finfo.Datasets.Dataspace});
size_excitation = dimsizes(strcmp('excitation_wavelengths', dimnames));
size_emission = dimsizes(strcmp('emission_wavelengths', dimnames));
size_power = dimsizes(strcmp('power_measurements', dimnames));

obj.spectrometer.spectra = NaN(obj.xystage.xnum, obj.xystage.ynum, ...
    size_excitation, size_emission);
obj.powermeter.power = NaN(obj.xystage.xnum, obj.xystage.ynum,...
    size_excitation, size_power);
obj.xystage.coordinates = NaN(obj.xystage.xnum, obj.xystage.ynum, 2);

% sm_resp = xlsread('QE65000_Efficiency.xlsx');

% rounding the wavelengths is necessary for finding indices later
obj.spectrometer.wavelengths = round(...
    h5read(obj.fname, '/dark/emission'), 2);
obj.spectrometer.darkspectrum = h5read(obj.fname, '/dark/spectrum'); 
obj.laser.excitation_wavelengths = round(...
    h5read(obj.fname, '/x1y1/excitation'), 2); 

if length(obj.laser.excitation_wavelengths) ~= obj.laser.wlnum
    obj.laser.wlnum = length(obj.laser.excitation_wavelengths); 
end

%% Read in all the measurement data

for x=1:obj.xystage.xnum
    for y=1:obj.xystage.ynum
        group = sprintf('/x%dy%d/',x,y);
        spectrum = h5read(obj.fname, [group 'spectrum']);
        spectrum = permute(spectrum, [2 1]);
        obj.spectrometer.spectra(x,y,:,:) = spectrum;
        power = h5read(obj.fname,  [group 'power']); 
        power = permute(power, [2 1]); 
        obj.powermeter.power(x,y,:,:) = power;
        obj.xystage.coordinates(x,y,:) = h5read(obj.fname, [group 'position']);

    end
end

%% Read the beamsplitter calibration file 
obj.beamsplitter.wavelengths = unique(h5read(obj.fname, ...
    '/calibration_beamsplitter/wavelength')); 
total_samples = length(h5read(obj.fname, ...
    '/calibration_beamsplitter/wavelength')); 
wls = length(obj.beamsplitter.wavelengths);
samples = total_samples/wls; 

obj.beamsplitter.power_pm = reshape(h5read(obj.fname, ...
    '/calibration_beamsplitter/power_1'), samples, wls)'; 
obj.beamsplitter.times_pm = reshape(h5read(obj.fname, ...
    '/calibration_beamsplitter/times_1'), samples, wls)'; 
obj.beamsplitter.power_sample = reshape(h5read(obj.fname, ...
    '/calibration_beamsplitter/power_2'), samples, wls)'; 
obj.beamsplitter.times_sample = reshape(h5read(obj.fname, ...
    '/calibration_beamsplitter/times_2'), samples, wls)'; 

mean_pm = mean(obj.beamsplitter.power_pm, 2);
mean_sample = mean(obj.beamsplitter.power_sample, 2);

obj.beamsplitter.correction_pm_to_sample = ...
    mean_sample./(mean_pm);

end

