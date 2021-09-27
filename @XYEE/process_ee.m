function [ obj ] = process_ee( obj )
%PROCESS_EE Processes XYEE excitation/emission data
%   Returns: an XYEE object

%% Turn off specific warnings
warning('off', 'curvefit:prepareFittingData:removingNaNAndInf');

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

obj.spectrometer.wavelengths = h5read(obj.fname, '/dark/emission');
obj.spectrometer.darkspectrum = h5read(obj.fname, '/dark/spectrum'); 
obj.laser.excitation_wavelengths = h5read(obj.fname, '/x1y1/excitation'); 

%% Read in all the data 

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


%% Turn all warnings back on
warning('on', 'curvefit:prepareFittingData:removingNaNAndInf');
end

