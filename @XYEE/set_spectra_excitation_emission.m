function obj = set_spectra_excitation_emission(obj, varargin) 
% Applies corrections to the spectra measured with the spectrometer.
% Default is to subtract darkspectrum and correct for incoming power. Other
% options are raw data, or only dark spectrum removed. 
% In the full power correction, the correction for the beamsplitter is also
% applied. The power from the powermeter is converted into photon flux 
% through E = hf. 


if isempty(varargin)
    correctiontype = 'Corrected for Power and Dark';  
else
    correctiontype = varargin{1}; 
end

disp(correctiontype)

switch correctiontype
    case 'Raw Spectra'
        obj.plotdata.spectra_emission = obj.spectrometer.spectra; 
    case 'Dark Removed' 
        darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
            obj.xystage.xnum, obj.xystage.ynum, ...
            obj.laser.wlnum); 
        darkrepeat = permute(darkrepeat, [2 3 4 1]); 
        obj.plotdata.spectra_emission = ...
            obj.spectrometer.spectra-darkrepeat; 
    case 'Corrected for Power and Dark'
        darkrepeat = repmat(obj.spectrometer.darkspectrum, 1, ...
            obj.xystage.xnum, obj.xystage.ynum, obj.laser.wlnum); 
        darkrepeat = permute(darkrepeat, [2 3 4 1]); 

        wls = repmat(obj.laser.excitation_wavelengths, 1,...
            obj.xystage.xnum, obj.xystage.ynum);
        % change unit from nm to m
        wls = permute(wls, [2 3 1])*1e-9; 

        h = 6.626e-34;     % planck constant
        c = 2.997e8;       % speed of light 

        power_averaged = mean(obj.powermeter.power, 4); 
        flux_averaged = power_averaged.* ...
            wls./(h*c); 
        obj.powermeter.flux_normalized = flux_averaged./ ...
            max(flux_averaged, [], 3); 
        
        % interpolate beamsplitter calibration file with actual 
        % power measurements
        correction_beamsplitter = interp1(obj.beamsplitter.wavelengths, ...
            obj.beamsplitter.correction_pm_to_sample, ...
            obj.laser.excitation_wavelengths); 
        correction_beamsplitter = repmat(...
            correction_beamsplitter, 1, ...
            obj.xystage.xnum, obj.xystage.ynum); 
        correction_beamsplitter = permute(correction_beamsplitter, ...
            [2 3 1]); 
        
        correction_total = correction_beamsplitter.*flux_averaged;
        correction_total = correction_total./max(correction_total, [], 3);

        obj.plotdata.spectra_emission = obj.spectrometer.spectra - ...
            darkrepeat; 
        obj.plotdata.spectra_emission = obj.plotdata.spectra_emission./... 
             correction_total; 
end



