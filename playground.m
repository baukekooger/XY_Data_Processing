clc
clear all
close all 

fname = uigetfile('*.hdf5'); 
info = h5info(fname);
experiments = {info.Groups.Name}; 
experiments = erase(experiments, '/'); 





%% 
transmissioncontents = string({info.Groups.Groups.Name});
transmissioncontents = erase(transmissioncontents, '/transmission/'); 
data.emission_wavelengths = h5read(fname,'/transmission/emission_wavelengths');
data.excitation_wavelengths = h5read(fname,'/transmission/excitation_wavelengths');
data.spectrometer_intervals = h5read(fname,'/transmission/spectrometer_intervals');
data.xy_position = h5read(fname,'/transmission/xy_position');
data.dark.emission = h5read(fname,'/transmission/dark/emission');
data.dark.position = h5read(fname,'/transmission/dark/position');
data.dark.spectrum = h5read(fname,'/transmission/dark/spectrum');
data.dark.spectrum_t = h5read(fname,'/transmission/dark/spectrum_t');


